import os
from shutil import rmtree

import numpy as np
import torch
from tabulate import tabulate
from torch.nn.functional import cross_entropy
from sklearn.metrics import f1_score, precision_recall_fscore_support
from dgl.dataloading import GraphDataLoader
from torch.utils.tensorboard import SummaryWriter

from sco_models.dataloader import EthIdsDataset
# from sco_models.model_hetero import MANDOGraphClassifier
from sco_models.model_hgt import HGTVulGraphClassifier
from sco_models.visualization import visualize_average_k_folds, visualize_k_folds
from sco_models.utils import score, get_classification_report, get_confusion_matrix


def train(args, model, train_loader, optimizer, loss_fcn, epoch):
    model.train()
    total_accucracy =  0
    total_macro_f1 = 0
    total_micro_f1 = 0
    total_loss = 0
    circle_lrs = []
    for idx, (batched_graph, labels) in enumerate(train_loader):
        labels = labels.to(args['device'])
        optimizer.zero_grad()
        logits, _ = model(batched_graph)
        loss = loss_fcn(logits, labels)
        train_acc, train_micro_f1, train_macro_f1, train_buggy_f1 = score(labels, logits)
        loss.backward()
        # torch.nn.utils.clip_grad_norm_(model.parameters(), 1e-3)
        optimizer.step()
        total_accucracy += train_acc
        total_micro_f1 += train_micro_f1
        total_macro_f1 += train_macro_f1
        total_loss += loss.item()
        circle_lrs.append(optimizer.param_groups[0]["lr"])
    steps = idx + 1
    return model, total_loss/steps, total_micro_f1/steps, train_macro_f1/steps, total_accucracy/steps, train_buggy_f1/steps, circle_lrs


def test(args, model, test_loader):
    model.eval()
    total_macro_f1 = 0
    total_micro_f1 = 0
    total_accucracy =  0
    total_logits = []
    total_target = []
    predictions_dict = {}
    
    # Get reverse mapping from index to filename
    index_to_filename = {v: k for k, v in test_loader.dataloader.dataset.filename_mapping.items()}
    
    with torch.no_grad():
        for idx, (batched_graph, labels) in enumerate(test_loader):
            labels = labels.to(args['device'])
            logits, _ = model(batched_graph, './forensics/graph_hiddens/reentrancy/creation_last_attention.pt')
            predicted_classes = torch.argmax(logits, dim=1)
            for i, pred in enumerate(predicted_classes):
                contract_index = idx * args.get('batch_size', 256) + i
                filename = index_to_filename.get(contract_index, f'unknown_{contract_index}')
                predictions_dict[filename] = pred.item()
            total_logits += logits.tolist()
            total_target += labels.tolist()
            test_acc, test_micro_f1, test_macro_f1, _ = score(labels, logits)
            total_accucracy += test_acc
            total_micro_f1 += test_micro_f1
            total_macro_f1 += test_macro_f1
    steps = idx + 1
    total_logits = torch.tensor(total_logits)
    total_target = torch.tensor(total_target)
    classification_report = get_classification_report(total_target, total_logits, output_dict=True)
    confusion_report = get_confusion_matrix(total_target, total_logits)
    return total_micro_f1/steps, test_macro_f1/steps, total_accucracy/steps, classification_report, confusion_report, predictions_dict


def main(args):
    epochs = args['num_epochs']
    device = args['device']
    ethdataset = EthIdsDataset(args['label'])
    
    # Get feature extractor
    print('Getting features')
    if args['node_feature'] == 'han':
        feature_extractor = HGTVulGraphClassifier(args['feature_compressed_graph'], node_feature='nodetype', hidden_size=16, device=args['device'])
        feature_extractor.load_state_dict(torch.load(args['feature_extractor']))
        feature_extractor.to(args['device'])
        feature_extractor.eval()
    else:
        feature_extractor = args['feature_extractor']

    # Train on full dataset
    train_results = {'loss': [], 'acc': [], 'micro_f1': [], 'macro_f1': [], 'buggy_f1': [], 'lrs': []}
    
    # Use all data for training
    train_dataloader = GraphDataLoader(ethdataset, batch_size=args['batch_size'], drop_last=False, shuffle=True)
    
    print('Start training with {} smart contracts'.format(len(ethdataset)))
    
    model = HGTVulGraphClassifier(args['compressed_graph'], feature_extractor=feature_extractor, node_feature=args['node_feature'], device=device)
    model.reset_parameters()
    model.to(device)
    
    loss_fcn = torch.nn.CrossEntropyLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.0005)
    scheduler = torch.optim.lr_scheduler.OneCycleLR(optimizer, max_lr=0.01, total_steps=epochs)
    
    for epoch in range(epochs):
        print('Epoch {}'.format(epoch))
        model, train_loss, train_micro_f1, train_macro_f1, train_acc, train_buggy_f1, lrs = train(args, model, train_dataloader, optimizer, loss_fcn, epoch)
        print('Train Loss: {:.4f} | Train Micro f1: {:.4f} | Train Macro f1: {:.4f} | Train Accuracy: {:.4f}'.format(
                train_loss, train_micro_f1, train_macro_f1, train_acc))
        
        scheduler.step()
        
        train_results['loss'].append(train_loss)
        train_results['micro_f1'].append(train_micro_f1)
        train_results['macro_f1'].append(train_macro_f1)
        train_results['acc'].append(train_acc)
        train_results['buggy_f1'].append(train_buggy_f1)
        train_results['lrs'] += lrs

    print('Saving model')
    save_path = os.path.join(args['output_models'], 'han_model.pth')
    torch.save(model.state_dict(), save_path)
    
    return train_results


def load_model(model_path, compressed_graph_path, feature_extractor, node_feature, device):
    model = HGTVulGraphClassifier(compressed_graph_path, feature_extractor=feature_extractor, node_feature=node_feature, device=device)
    model.load_state_dict(torch.load(model_path, map_location=device))
    return model.eval()


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser('MANDO Graph Classifier')
    parser.add_argument('-s', '--seed', type=int, default=1,
                        help='Random seed')
    archive_params = parser.add_argument_group(title='Storage', description='Directories for util results')
    archive_params.add_argument('-ld', '--log_dir', type=str, default='./logs/graph_classification', help='Directory for saving training logs and visualization')
    archive_params.add_argument('--output_models', type=str, default='./models/call_graph', help='Where you want to save your models')
    dataset_params = parser.add_argument_group(title='Dataset', description='Dataset paths')
    dataset_params.add_argument('--compressed_graph', type=str, default='./dataset/call_graph/compressed_graph/compress_call_graphs_no_solidity_calls.gpickle', help='Compressed graphs of dataset which was extracted by graph helper tools')
    dataset_params.add_argument('--dataset', type=str, default='./dataset/aggregate/source_code', help='Dicrectory of all souce code files which were used to extract the compressed graph')
    dataset_params.add_argument('--testset', type=str, default='./dataset/smartbugs/source_code', help='Dicrectory of all souce code files which is a partition of the dataset for testing')
    dataset_params.add_argument('--label', type=str, default='./dataset/aggregate/labels.json', help='Label of sources in source code storage')
    dataset_params.add_argument('--checkpoint', type=str, default='./models/ijcai2020_smartbugs/han_fold_1.pth', help='Checkpoint of trained models')
    node_feature_params = parser.add_argument_group(title='Node feature', description='Define the way to get node features')
    node_feature_params.add_argument('--feature_extractor', type=str, default='./models/metapath2vec_cfg/han_fold_1.pth', help='If "node_feature" is "GAE" or "LINE" or "Node2vec", we need a extracted features from those models')
    node_feature_params.add_argument('--node_feature', type=str, default='metapath2vec', help='Kind of node features we want to use, here is one of "nodetype", "metapath2vec", "han", "gae", "line", "node2vec"')
    train_option_params = parser.add_argument_group(title='Optional configures', description='Advanced options')
    train_option_params.add_argument('--test', action='store_true', help='Set true if you only want to run test phase')
    train_option_params.add_argument('--non_visualize', action='store_true', help='Wheather you want to visualize the metrics')
    args = parser.parse_args().__dict__

    default_configure = {
    'lr': 0.0005,             # Learning rate
    'num_heads': 8,        # Number of attention heads for node-level attention
    'hidden_units': 8,
    'dropout': 0.6,
    'weight_decay': 0.001,
    'num_epochs': 20,
    'batch_size': 256,
    'patience': 100,
    'device': 'cuda:0' if torch.cuda.is_available() else 'cpu'
    }
    args.update(default_configure)
    torch.manual_seed(args['seed'])

    if not os.path.exists(args['output_models']):
        os.makedirs(args['output_models'])

    # Training
    if not args['test']:
        print('Training phase')
        train_results = main(args)
        if not args['non_visualize']:
            print('Visualizing')
            if os.path.exists(args['log_dir']):
                rmtree(args['log_dir'])
            # Can implement single model visualization if needed
    # Testing
    else:
        print('Testing phase')
        ethdataset = EthIdsDataset(args['label'], args['testset'])
        smartbugs_ids = [ethdataset.filename_mapping[sc] for sc in os.listdir(args['testset']) if sc.endswith('.sol')]
        test_dataloader = GraphDataLoader(ethdataset, batch_size=256, drop_last=False, sampler=smartbugs_ids)

        model_path = '/workspaces/mlsc/mando/ge-sc-transformer/models/graph_classification/cfg_cg/node_features3/han_model.pth'
        model = load_model(model_path, args['compressed_graph'], args['feature_extractor'], args['node_feature'], args['device'])
        test_micro_f1, test_macro_f1, test_acc, _, _, predictions = test(args, model, test_dataloader)
        print('Test Micro f1:   {:.4f} | Test Macro f1:   {:.4f} | Test Accuracy:   {:.4f}'.format(test_micro_f1, test_macro_f1, test_acc))
        # Here you can access the predictions_dict for each contract's prediction
        for filename, prediction in predictions.items():
            print(f'Contract {filename} - Predicted class: {prediction}')
# python graph_classifier.py \
#     -ld ./logs/graph_classification/cfg_cg/node_features \
#     --output_models ./models/graph_classification/cfg_cg/node_features \
#     --dataset ./experiments/ge-sc-data/source_code/reentrancy/cgt/train \
#     # --testset ./experiments/ge-sc-data/source_code/reentrancy/cgt/test \
#     --compressed_graph ./experiments/ge-sc-data/source_code/reentrancy/cgt/cfg_cg_compressed_graphs.gpickle \
#     --label ./experiments/ge-sc-data/source_code/reentrancy/cgt/mando_labels.json \
#     --node_feature nodetype \
#     --seed 1

python graph_classifier.py \
    -ld ./logs/graph_classification/cfg_cg/node_features \
    --output_models ./models/graph_classification/cfg_cg/node_features \
    --dataset ./experiments/ge-sc-data/source_code/reentrancy/cgt \
    --compressed_graph ./experiments/ge-sc-data/source_code/reentrancy/cgt/cfg_cg_compressed_graphs.gpickle \
    --label ./experiments/ge-sc-data/source_code/reentrancy/cgt/mando_labels.json \
    --node_feature nodetype \
    --seed 1
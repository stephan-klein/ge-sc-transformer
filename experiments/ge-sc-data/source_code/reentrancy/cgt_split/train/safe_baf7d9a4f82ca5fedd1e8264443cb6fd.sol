pragma solidity ^0.4.9;

contract TimeStamp{
    
    struct AckReceipt {
        
        bool exists;
        address receiver;
        string login;
        string dateReceipt;
    }

    struct SharedDocument {

        string sharedDocumentId;
        string dateShared;
        string sharedLogin;
    }
    
    struct Download {
        string dateDownload;
        string login;
    }

    struct DocumentRecord {

        bool exists;
        string dateUploaded;
        string documentHash;
        string ownerLogin;
        string dateDeleted;
        SharedDocument[] sharedDocuments;
        Download[] downloads;
    }


    address owner;
    address newContract;
    address oldContract;

    //Mapping documentId => DocumentRecord
    mapping(string => DocumentRecord) documentRecords;
    string[] documentIds;
    
    //Mapping sharedDocumentId => remove date
    mapping(string => string) sharedDocumentsRemoveDate;
    
    //Mapping sharedDocumentId => AckReceipt
    mapping(string => AckReceipt) sharedDocumentsAckReceipt;
    
    


    //modifier ownercontract { if(msg.sender == owner || msg.sender == newContract) _;}
    modifier onlyowner { if(msg.sender == owner) _;}


    function TimeStamp() payable {
        owner = msg.sender;
    }


    function getDocumentRecord(uint _index) constant 
        returns(string o_documentId, string o_dateUploaded, uint o_numberShares, uint o_numberDownloads, string o_documentHash, string o_ownerLogin, string o_dateDeleted){

        if(_index >= documentIds.length){
            throw;
        }

        DocumentRecord result = documentRecords[documentIds[_index]];
        return (documentIds[_index], result.dateUploaded, result.sharedDocuments.length, result.downloads.length, result.documentHash, result.ownerLogin, result.dateDeleted);
    }


    function getDocumentRecordById(string _documentId) constant 
        returns(string o_dateUploaded, uint o_numberShares, uint o_numberDownloads, string o_ownerLogin, string o_documentHash, string o_dateDeleted){

        DocumentRecord result = documentRecords[_documentId];
        return (result.dateUploaded, result.sharedDocuments.length, result.downloads.length, result.ownerLogin, result.documentHash, result.dateDeleted);
    }


    function getSharedDocument(string _documentId, uint _sharedDocumentIndex) constant 
                                        returns(string o_sharedDocumentId, string o_dateShared, string o_sharedLogin, string o_dateReceipt, string o_dateRemoved){

        DocumentRecord result = documentRecords[_documentId];
        
        if(!result.exists){
            throw;
        }
        
        SharedDocument sharedResult = result.sharedDocuments[_sharedDocumentIndex];

        return (sharedResult.sharedDocumentId, sharedResult.dateShared, sharedResult.sharedLogin, 
                sharedDocumentsAckReceipt[sharedResult.sharedDocumentId].dateReceipt, sharedDocumentsRemoveDate[sharedResult.sharedDocumentId]);
    }
    
    
    function getDocumentDownload(string _documentId, uint _documentDownloadIndex) constant returns(string o_dateDownload, string o_login){

        DocumentRecord result = documentRecords[_documentId];
        
        if(!result.exists){
            throw;
        }
        
        Download downloadResult = result.downloads[_documentDownloadIndex];

        return (downloadResult.dateDownload, downloadResult.login);
    }
    
    
    function getDocumentRecordsNumber() constant returns (uint n){

        return documentIds.length;
    }


    function addDocumentRecord(string _documentId, string _dateUploaded, string _documentHash, string _ownerLogin) onlyowner returns (uint o_index) {

        if(documentRecords[_documentId].exists){
            throw;
        }

        uint index = documentIds.length;
        documentIds.length++;
        documentIds[index] = _documentId;

        documentRecords[_documentId].exists = true;
        documentRecords[_documentId].dateUploaded = _dateUploaded;
        documentRecords[_documentId].documentHash = _documentHash;
        documentRecords[_documentId].ownerLogin = _ownerLogin;

        return index;
    }
    
    
    function addDocumentDownload(string _documentId, string _dateDownload, string _login) onlyowner returns (uint o_index) {
        
        DocumentRecord record = documentRecords[_documentId];
        if(!record.exists){
            throw;
        }
        
        uint index = record.downloads.length;
        record.downloads.length++;
        record.downloads[index].login = _login;
        record.downloads[index].dateDownload = _dateDownload;
        
        return index;
    }
    
    
    function setDocumentDeleteDate(string _documentId, string _deleteDate) onlyowner returns (uint o_index) {
        
        DocumentRecord record = documentRecords[_documentId];
        if(!record.exists || (bytes(record.dateDeleted).length > 0)){
            throw;
        }
        
        record.dateDeleted = _deleteDate;
        return 0;
    }


    function addSharedDocument(string _documentId, string _dateShared, string _sharedDocumentId, string _sharedLogin) onlyowner returns (uint o_index) {

        DocumentRecord record = documentRecords[_documentId];
        if(!record.exists){
            throw;
        }

        uint index = record.sharedDocuments.length;
        record.sharedDocuments.length++;
        record.sharedDocuments[index].sharedDocumentId = _sharedDocumentId;
        record.sharedDocuments[index].dateShared = _dateShared;
        record.sharedDocuments[index].sharedLogin = _sharedLogin;

        return index;
    }
    
    
    function setSharedDocumentRemoveDate(string _sharedDocumentId, string dateRemoved) onlyowner returns (uint o_index) {
        
        if(bytes(sharedDocumentsRemoveDate[_sharedDocumentId]).length > 0){
            throw;
        }
        
        sharedDocumentsRemoveDate[_sharedDocumentId] = dateRemoved;
        return 0;
    }    
    

    function setSharedDocumentAckReceipt(string _sharedDocumentId, string _dateReceipt, string _login) returns (uint o_index) {
        
        if(sharedDocumentsAckReceipt[_sharedDocumentId].exists){
            throw;
        }
        
        sharedDocumentsAckReceipt[_sharedDocumentId].exists = true;
        sharedDocumentsAckReceipt[_sharedDocumentId].dateReceipt = _dateReceipt;
        
        if(msg.sender != owner){
            sharedDocumentsAckReceipt[_sharedDocumentId].receiver = msg.sender;
            sharedDocumentsAckReceipt[_sharedDocumentId].login = _login;
        }
        
        return 0;
    }
    
    
    function setSharedDocumentAckReceiptOwner(string _sharedDocumentId, string _dateReceipt) onlyowner returns (uint o_index) {
        
        if(sharedDocumentsAckReceipt[_sharedDocumentId].exists){
            throw;
        }
        
        sharedDocumentsAckReceipt[_sharedDocumentId].exists = true;
        sharedDocumentsAckReceipt[_sharedDocumentId].dateReceipt = _dateReceipt;
        
        return 0;
    }


    function setOwner(address _newOwner) onlyowner {
        owner = _newOwner;
    }


    function setNewContract(address _newContract) onlyowner {
        newContract = _newContract;
    }


    function setOldContract(address _oldContract) onlyowner {
        oldContract = _oldContract;
    }


    function getOldContract() onlyowner constant returns (address o_a){
        return oldContract;
    }
    
    
    function destroy() onlyowner {
        suicide(owner); // send funds to owner
    }


    function isOwner() constant onlyowner returns(bool o_b){
        return true;
    }


    function getOwner() constant returns (address o_a){
        return owner;
    }

}
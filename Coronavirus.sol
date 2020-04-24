pragma solidity >=0.4.22 <0.7.0;
contract Aggregator{
    
    
    address public owner;
   
    struct oracle_type{
        bool exists;
        int infected;
        int recovered;
        int dead;
        int credibility;
        uint lastUpdate;
   }
    
    mapping(address=>oracle_type) public Oracles;
    
    address[] oraclesArray;
    
    int public averageinfected;
    int public averagerecovered;
    int public averagedead; 
    
    int tolerance_thresold;

    struct head{
       int value;
       int votes;
       int infectedCenter;
       int reocveredCenter;
       int deadCenter;
       int cr;
   }
   
   head[] public heads;
   
    constructor()public{
        owner = msg.sender;
        averageinfected= 0;
        averagerecovered= 0;
        averagedead=0; 
        tolerance_thresold = 5;

    }
   
    modifier onlyOwner() { 
        require(
            msg.sender == owner,
            "Only contract owner can call this."
        );
        _;
    }
   
    modifier onlyOracle{ 
        require(
            Oracles[msg.sender].exists,
            "Only Oracle can call this."
        );
        _;
    }
    
   event OracleInput(address oracleAddress, int newInfected,int newRecovered, int newDead);
   
   function registerOracle (address oracleAddress) public onlyOwner{
       require(
            !Oracles[oracleAddress].exists,
            "Oracle already registred."
        );
       Oracles[oracleAddress].exists=true;
       Oracles[oracleAddress].credibility=80;
       oraclesArray.push(oracleAddress);
   }
   
   function inputOracle(int infect,int recover,int  death) public onlyOracle {
       
       Oracles[msg.sender].infected+=infect;
       Oracles[msg.sender].recovered+=recover;
       Oracles[msg.sender].dead+=death;
       
       Oracles[msg.sender].lastUpdate=now;

       emit OracleInput(msg.sender, Oracles[msg.sender].infected, Oracles[msg.sender].recovered, Oracles[msg.sender].dead);


   }
    
    function calculatestatistics() public{
        
        head memory t;
        delete heads;
        t.votes = 1;
        t.value = Oracles[oraclesArray[0]].infected;
        t.infectedCenter = t.value;
        t.reocveredCenter = Oracles[oraclesArray[0]].recovered;
        t.deadCenter = Oracles[oraclesArray[0]].dead;
        t.cr = Oracles[oraclesArray[0]].credibility;
        heads.push(t);
        for(uint i = 1;i<oraclesArray.length;i++){
            int min = 1000;
            uint min_index;
                    for(uint j = 0;j<heads.length;j++){
                        int temp = heads[j].value-Oracles[oraclesArray[i]].infected;
                        if(temp<=tolerance_thresold && temp<min && temp>=0){
                            min = temp;
                            min_index = j;
                        }
                        else {
                            temp *= -1;
                            if(temp<=tolerance_thresold && temp<min && temp>=0){
                                min = temp;
                                min_index = j;
                            }
                        }
                    }
                    if(min!=1000){
                        heads[min_index].votes++;
                        heads[min_index].cr += Oracles[oraclesArray[i]].credibility;
                        heads[min_index].infectedCenter += Oracles[oraclesArray[i]].infected;
                        heads[min_index].reocveredCenter += Oracles[oraclesArray[i]].recovered;
                        heads[min_index].deadCenter += Oracles[oraclesArray[i]].dead;
                    }
                    else{
                        t.votes = 1;
                        t.value = Oracles[oraclesArray[i]].infected;
                        t.infectedCenter = t.value;
                        t.reocveredCenter = Oracles[oraclesArray[i]].infected;
                        t.deadCenter = Oracles[oraclesArray[i]].recovered;
                        t.cr = Oracles[oraclesArray[i]].dead;
                        heads.push(t);
                    }
        }
        int max = 0;
        for(uint j = 0;j<heads.length;j++){
                     if(heads[j].cr>=max){
                         max = heads[j].cr;
                         averageinfected = heads[j].infectedCenter/heads[j].votes;
                         averagerecovered = heads[j].reocveredCenter/heads[j].votes;
                         averagedead = heads[j].deadCenter/heads[j].votes;
                     }
        }
    }
    
}
  

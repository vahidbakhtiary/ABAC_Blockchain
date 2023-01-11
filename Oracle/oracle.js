const Web3 = require('web3')

const SRMC = require('../Root/build/contracts/SRMC.json');
const APSC = require('../Root/build/contracts/APSC.json');

const Subject_APMC = require('../SubjectShard/build/contracts/APMC.json');
const Object_APMC = require('../ObjectShard/build/contracts/APMC.json');

 



let number = getCount()
let counter = 0;
const gas = 3000000
const gasLimit = 300000000000

let logs = []



var contractSRMC;
var contractAPSC;
var contractSubject_APMC;
var contractObject_APMC;

const web3_acc = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:8545'));
const web3_object = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:8546'));
const web3_subject = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:8547'));

contractSRMC = new web3_acc.eth.Contract(SRMC.abi, SRMC.networks['15333'].address);
contractAPSC = new web3_acc.eth.Contract(APSC.abi, APSC.networks['15333'].address);
contractObject_APMC = new web3_object.eth.Contract(Object_APMC.abi, Object_APMC.networks['15334'].address);
contractSubject_APMC = new web3_subject.eth.Contract(Subject_APMC.abi, Subject_APMC.networks['15335'].address);





init()
let accounts;
let subjectAccounts;
let objectAccounts;
let blockNumber = 0;

async function init() {


    accounts = await web3_acc.eth.getAccounts();
    subjectAccounts = await web3_subject.eth.getAccounts();
    objectAccounts = await web3_object.eth.getAccounts();

    blockNumber = await web3_acc.eth.getBlockNumber();
 
    contractAPSC.events.AddPolicyEvent(
        { fromBlock: blockNumber, step: 0 }
    )
        .on('data', async event => { 

            Promise.all([
                await contractSubject_APMC.methods.addPolicy(event.returnValues.requestId, event.returnValues.resource, event.returnValues.sa, event.returnValues.action).send({ from: subjectAccounts[0], gas: gas, gasLimit: gasLimit }),
                await contractObject_APMC.methods.addPolicy(event.returnValues.requestId, event.returnValues.resource, event.returnValues.oa, event.returnValues.action).send({ from: objectAccounts[0], gas: gas, gasLimit: gasLimit })
            ]) 
  
            await contractAPSC.methods
            .callbackAddPolicy(event.returnValues.requestId, true)
            .send({ from: accounts[0], gas: gas, gasLimit: gasLimit })

        }); 

        contractAPSC.events.UpdatePolicyEvent(
            { fromBlock: blockNumber, step: 0 }
        )
            .on('data', async event => { 
    
                Promise.all([
                    await contractSubject_APMC.methods.updatePolicy(event.returnValues.requestId, event.returnValues.resource, event.returnValues.sa, event.returnValues.action).send({ from: subjectAccounts[0], gas: gas, gasLimit: gasLimit }),
                    await contractObject_APMC.methods.updatePolicy(event.returnValues.requestId, event.returnValues.resource, event.returnValues.oa, event.returnValues.action).send({ from: objectAccounts[0], gas: gas, gasLimit: gasLimit })
                ]) 
      
                await contractAPSC.methods
                .callbackUpdatePolicy(event.returnValues.requestId, true)
                .send({ from: accounts[0], gas: gas, gasLimit: gasLimit })
    
            });    
        
            contractAPSC.events.DeletePolicyEvent(
                { fromBlock: blockNumber, step: 0 }
            )
                .on('data', async event => { 
        
                    Promise.all([
                        await contractSubject_APMC.methods.deletePolicy(event.returnValues.requestId, event.returnValues.resource, event.returnValues.sa, event.returnValues.action).send({ from: subjectAccounts[0], gas: gas, gasLimit: gasLimit }),
                        await contractObject_APMC.methods.deletePolicy(event.returnValues.requestId, event.returnValues.resource, event.returnValues.oa, event.returnValues.action).send({ from: objectAccounts[0], gas: gas, gasLimit: gasLimit })
                    ]) 
          
                    await contractAPSC.methods
                    .callbackDeletePolicy(event.returnValues.requestId, true)
                    .send({ from: accounts[0], gas: gas, gasLimit: gasLimit })
        
                }); 

    contractSRMC.events.AccessControlEvent(
        { fromBlock: blockNumber, step: 0 }
    )
        .on('data', async event => {  

             const subject_result=contractSubject_APMC.methods.accessControl(event.returnValues.from, event.returnValues.resource, event.returnValues.action).call();
             const object_result=contractObject_APMC.methods.accessControl(event.returnValues.resource, event.returnValues.resource, event.returnValues.action).call();

            await contractSRMC.methods
            .callbackAccessControl(event.returnValues.requestId, subject_result , object_result)
            .send({ from: accounts[0], gas: gas, gasLimit: gasLimit })
        }); 
}
 
 
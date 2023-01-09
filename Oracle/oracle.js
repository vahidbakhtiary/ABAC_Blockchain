const Web3 = require('web3')

const AccessControlContract = require('../Root/build/contracts/AccessControl.json');
const SubjectContract = require('../SubjectGroup/build/contracts/SubjectContract.json');
const ObjectContract = require('../ObjectGroup/build/contracts/ObjectContract.json');

const fs = require('fs');



let number = getCount()
let counter = 0;
const gas = 3000000
const gasLimit = 300000000000

let logs = []



var contractACC;
var contractSubject;
var contractObject;

const web3_acc = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:8545'));
const web3_object = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:8546'));
const web3_subject = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:8547'));

contractACC = new web3_acc.eth.Contract(AccessControlContract.abi, AccessControlContract.networks['15333'].address);
contractObject = new web3_object.eth.Contract(ObjectContract.abi, ObjectContract.networks['15334'].address);
contractSubject = new web3_subject.eth.Contract(SubjectContract.abi, SubjectContract.networks['15335'].address);





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
 
    contractACC.events.AddPolicyEvent(
        { fromBlock: blockNumber, step: 0 }
    )
        .on('data', async event => { 

            Promise.all([
                await contractSubject.methods.addPolicy(event.returnValues.requestId, event.returnValues.resource, event.returnValues.sa, event.returnValues.action).send({ from: subjectAccounts[0], gas: gas, gasLimit: gasLimit }),
                await contractObject.methods.addPolicy(event.returnValues.requestId, event.returnValues.resource, event.returnValues.oa, event.returnValues.action).send({ from: objectAccounts[0], gas: gas, gasLimit: gasLimit })
            ]) 
  
            await contractACC.methods
            .callbackAddPolicy(event.returnValues.requestId, true)
            .send({ from: accounts[0], gas: gas, gasLimit: gasLimit })

        }); 

    contractACC.events.AccessControlEvent(
        { fromBlock: blockNumber, step: 0 }
    )
        .on('data', async event => {  

             const subject_result=contractSubject.methods.accessControl(event.returnValues.from, event.returnValues.resource, event.returnValues.action).call();
             const object_result=contractObject.methods.accessControl(event.returnValues.resource, event.returnValues.resource, event.returnValues.action).call();

            await contractACC.methods
            .callbackAccessControl(event.returnValues.requestId, subject_result , object_result)
            .send({ from: accounts[0], gas: gas, gasLimit: gasLimit })
        }); 
}
 
 
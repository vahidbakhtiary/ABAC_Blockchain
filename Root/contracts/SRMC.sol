// SPDX-License-Identifier:MIT
pragma solidity >=0.4.22 <0.9.0;

 

contract SRMC {

    

    //Event
    event ReturnAccessResult(address indexed from, string result);    
    event AccessControlEvent(uint requestId, address from, address resource, string action);
    event CallbackAccessControlEvent(uint requestId , string result);

      

    //check for access control      
    function accessControl(uint requestId, address _resource, string memory _action) public {            
        emit AccessControlEvent(requestId ,  msg.sender, _resource, _action );
    }

    function callbackAccessControl(uint _requestId, bool sa_result, bool oa_result) public
    {         
        if (sa_result && oa_result)
            emit CallbackAccessControlEvent(_requestId , "Allow" );
        else
            emit CallbackAccessControlEvent(_requestId , "Deny" );
    }
    

     
}

// SPDX-License-Identifier:MIT
pragma solidity >=0.4.22 <0.9.0;


contract APSC {

 //variables
    address owner;

    // constructor
    constructor() {
        owner = msg.sender;
    }

    //Event    
    event AddPolicyEvent(
         uint requestId,
        address resource,
        string[] sa,
        string[] oa,
        string action       
    );
    event UpdatePolicyEvent(
         uint requestId,
        address resource,
        string[] sa,
        string[] oa,
        string action        
    );
    event DeletePolicyEvent(
         uint requestId,
        address resource,
        string[] sa,
        string[] oa,
        string action       
    );
    event CallbackAddPolicyEvent(uint requestId, bool result);
    event CallbackUpdatePolicyEvent(uint requestId, bool result);
    event CallbackDeletePolicyEvent(uint requestId, bool result);
    

     

    // add Policy
    function addPolicy(
        uint _requestId,       //Request order Id
        address _resource,     //Object Address
        string[] memory _sa,   //Subject Attributes
        string[] memory _oa,   //Object Attributes
        string memory _action  //Operation
    )
        public
    {
 
        require(msg.sender == owner, "addPolicy error: Caller is not owner!");  
        require(_sa.length % 2 != 0, "addPolicy error: invalid experssion!");
        require(_oa.length % 2 != 0, "addPolicy error: invalid experssion!");

        for (uint256 i = 0; i < _sa.length; i += 4) {
            if (
                !stringCompare(_sa[i + 2], ">") &&
                !stringCompare(_sa[i + 2], "<") &&
                !stringCompare(_sa[i + 2], "=") &&
                !stringCompare(_sa[i + 2], "!=")
            ) {
                revert("addPolicy error: operator should be >, < or =");
            }
        }

        for (uint256 i = 0; i < _oa.length; i += 4) {
            if (
                !stringCompare(_oa[i + 2], ">") &&
                !stringCompare(_oa[i + 2], "<") &&
                !stringCompare(_oa[i + 2], "=") &&
                !stringCompare(_oa[i + 2], "!=")
            ) {
                revert("addPolicy error: operator should be >, < or =");
            }
        } 
         
        emit AddPolicyEvent( _requestId,_resource, _sa, _oa, _action);
    }

    function callbackAddPolicy(uint requestId, bool isOk) public {       
        emit CallbackAddPolicyEvent(requestId , isOk);
    }



    // update Policy
    function updatePolicy(
        uint _requestId,       //Request order Id
        address _resource,     //Object Address
        string[] memory _sa,   //Subject Attributes
        string[] memory _oa,   //Object Attributes
        string memory _action  //Operation
    )
        public
    {
 
        require(msg.sender == owner, "addPolicy error: Caller is not owner!"); 
        require(_sa.length % 2 != 0, "addPolicy error: invalid experssion!");
        require(_oa.length % 2 != 0, "addPolicy error: invalid experssion!");

        for (uint256 i = 0; i < _sa.length; i += 4) {
            if (
                !stringCompare(_sa[i + 2], ">") &&
                !stringCompare(_sa[i + 2], "<") &&
                !stringCompare(_sa[i + 2], "=") &&
                !stringCompare(_sa[i + 2], "!=")
            ) {
                revert("addPolicy error: operator should be >, < or =");
            }
        }

        for (uint256 i = 0; i < _oa.length; i += 4) {
            if (
                !stringCompare(_oa[i + 2], ">") &&
                !stringCompare(_oa[i + 2], "<") &&
                !stringCompare(_oa[i + 2], "=") &&
                !stringCompare(_oa[i + 2], "!=")
            ) {
                revert("addPolicy error: operator should be >, < or =");
            }
        } 
         
        emit UpdatePolicyEvent( _requestId,_resource, _sa, _oa, _action);
    }

    function callbackUpdatePolicy(uint requestId, bool isOk) public {       
        emit CallbackUpdatePolicyEvent(requestId , isOk);
    }
   
    

    // delete Policy
    function deletePolicy(
        uint _requestId,       //Request order Id
        address _resource,     //Object Address
        string[] memory _sa,   //Subject Attributes
        string[] memory _oa,   //Object Attributes
        string memory _action  //Operation
    )
        public
    {
 
        require(msg.sender == owner, "addPolicy error: Caller is not owner!");     
         
        emit DeletePolicyEvent( _requestId,_resource, _sa, _oa, _action);
    }

    function callbackDeletePolicy(uint requestId, bool isOk) public {       
        emit CallbackDeletePolicyEvent(requestId , isOk);
    }

    function stringCompare(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        bytes memory _a = bytes(a);
        bytes memory _b = bytes(b);
        if (_a.length != _b.length) {
            return false;
        } else {
            if (_a.length == 1) {
                return _a[0] == _b[0];
            } else {
                return
                    keccak256(abi.encodePacked(a)) ==
                    keccak256(abi.encodePacked(b));
            }
        }
    }

     function stringToUint(string memory s)
        public
        pure
        returns (uint256 result)
    {
        bytes memory b = bytes(s);
        uint256 i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }

}
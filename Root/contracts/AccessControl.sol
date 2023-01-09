// SPDX-License-Identifier:MIT
pragma solidity >=0.4.22 <0.9.0;

interface AttributeContract {
    function getAttribute(address _address, string memory _attrName)
        external
        view
        returns (string[] memory _attrValue);

    function addPolicy(        
        address _resource,       
        string[] memory _attrs,
        string memory _action
    ) external;

    function accessControl(
        address _from,
        address _resource,
        string memory _action
    ) external view returns (bool);
}

contract AccessControl {

    //variables
    address owner;

    // constructor
    constructor() {
        owner = msg.sender;
    }

    //Event
    event ReturnAccessResult(address indexed from, string result);
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
        string action , 
        uint smartContractStartTime
    );
    event CallbackAddPolicyEvent(uint requestId, bool result);
    event CallbackUpdatePolicyEvent(uint requestId, bool result);
    event AccessControlEvent(uint requestId, address from, address resource, string action);
    event CallbackAccessControlEvent(uint requestId , string result);

     

    function addPolicy(
        uint _requestId,       //Request order Id
        address _resource,     //Object Address
        string[] memory _sa,   //Subject Attributes
        string[] memory _oa,   //Object Attributes
        string memory _action  //Operation
    )
        public
    {
 
        require(msg.sender == owner, "addPolicy error: Caller is not owner!"); // If it is incorrect here, it reve 
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

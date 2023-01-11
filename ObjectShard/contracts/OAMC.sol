// SPDX-License-Identifier:MIT
pragma solidity >=0.4.22 <0.9.0;
 

contract OAMC { 
    

   //variables
    mapping(address => Resource) internal lookupTable;
     

    struct Resource {
        bool isValued;
        address manager;
        mapping(string => AttrValue) attrbutes;
    }

    struct AttrValue {
        bool isValued;        // check for duplicate 
        string value;         // attribute value
        string[] parentAttr;  // parent attributes
    }

    //modifier
    modifier isRegister(address _address) {
        require(lookupTable[_address].isValued, "Address not registered!");
        _;
    }

    modifier isAttributeExist(address _address, string memory _attrName) {
        require(
            !lookupTable[_address].attrbutes[_attrName].isValued,
            "add Attribute error: Attribute already exist!"
        );
        _;
    }
 

    //Register Object
    function addObject(address _address) public {
        lookupTable[_address].manager = msg.sender;
        lookupTable[_address].isValued = true;
    }

    
    
    //add Attribute for Object
    function addObjectAttr(
        address _address,        //Object Address
        string memory _attrName, //Object Attribute name
        string memory _attrValue,//Object Attribute value
        string[] memory _parent  //Object Attribute parents
    ) public isRegister(_address) {
        lookupTable[_address].attrbutes[_attrName].value = _attrValue;
        lookupTable[_address].attrbutes[_attrName].parentAttr = _parent;
        lookupTable[_address].attrbutes[_attrName].isValued = true;
    }
  
    //update Attribute for Object
    function updateObjectAttr(
        address _address,        //Object Address
        string memory _attrName, //Object Attribute name
        string memory _attrValue,//Object Attribute value
        string[] memory _parent  //Object Attribute parents
    ) public isRegister(_address) {
        lookupTable[_address].attrbutes[_attrName].value = _attrValue;
        lookupTable[_address].attrbutes[_attrName].parentAttr = _parent;
        lookupTable[_address].attrbutes[_attrName].isValued = true;
    }

    //delete Attribute for Object
    function deleteObjectAttr(
        address _address,        //Object Address
        string memory _attrName  //Object Attribute name        
    ) public isRegister(_address) {
        delete lookupTable[_address].attrbutes[_attrName] ;        
    }

    // expand of all attributes
    function expand(address _address, string memory _attrName)
        public
        view
        isRegister(_address)
        returns (string[] memory _attrValue)
    {
        string[] memory result = new string[](
            lookupTable[_address].attrbutes[_attrName].parentAttr.length + 1
        );

        result[0] = lookupTable[_address].attrbutes[_attrName].value;

        for (
            uint256 i = 0;
            i < lookupTable[_address].attrbutes[_attrName].parentAttr.length;
            i++
        ) {
            result[i + 1] = lookupTable[_address]
                .attrbutes[_attrName]
                .parentAttr[i];
        }

        return result;
    }
      

}



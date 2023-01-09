// SPDX-License-Identifier:MIT
pragma solidity >=0.4.22 <0.9.0;

contract ObjectContract {
    
    //variables
    mapping(address => Resource) lookupTable;
    mapping(address => mapping(string => PolicyItem[])) policies;

    //Struct
    struct PolicyItem {
        string[] attr; //Object attributes
        string action; //Operation
    }

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
    function register(address _address) public {
        lookupTable[_address].manager = msg.sender;
        lookupTable[_address].isValued = true;
    }

    //add policy for Object
    function addPolicy(        
        address _resource,     //Object Address
        string[] memory _attrs,//Object Attributes
        string memory _action  //Operation
    ) public {         
        policies[_resource][_action].push(PolicyItem(_attrs, _action));        
    } 

    //add Attribute for Object
    function addAttribute(
        address _address,        //Object Address
        string memory _attrName, //Object Attribute name
        string memory _attrValue,//Object Attribute value
        string[] memory _parent  //Object Attribute parents
    ) public isRegister(_address) {
        lookupTable[_address].attrbutes[_attrName].value = _attrValue;
        lookupTable[_address].attrbutes[_attrName].parentAttr = _parent;
        lookupTable[_address].attrbutes[_attrName].isValued = true;
    }

    // find attributes
    function getAttribute(address _address, string memory _attrName)
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

    
    //check Access control request
    function accessControl(
        address _from,
        address _resource,
        string memory _action
    ) public view returns (bool, uint256) {
        uint256 firstTime = block.timestamp;
        // check policies
        if (policies[_resource][_action].length == 0) {
            revert("NotDefine");
        }

        for (uint256 i = 0; i < policies[_resource][_action].length; i++) {
            bool isMatchPolicy = fetchAttribute(
                _from,
                policies[_resource][_action][i].attr
            );
            
            if (isMatchPolicy) return (true, firstTime);
        }

        return (false, firstTime);
    }

    function fetchAttribute(address _resource, string[] memory _policyAttr)
        private
        view
        returns (bool)
    {
        string[] memory attrValue;
        uint256 expersionLength;

        if (_policyAttr.length == 3) {
            expersionLength = 1;
        } else {
            expersionLength = (_policyAttr.length / 3) + 2;
        }
        string[] memory expersion = new string[](expersionLength);
        uint256 expersionCounter = 0;

        for (uint256 i = 0; i < _policyAttr.length; i += 4) {
            attrValue = getAttribute(_resource, _policyAttr[i]);
            bool result = compareAttribute(
                _policyAttr[i + 1],
                attrValue,
                _policyAttr[i + 2]
            );

            expersion[expersionCounter++] = result ? "true" : "false";

            if (_policyAttr.length - (i + 3) > 0) {
                expersion[expersionCounter++] = _policyAttr[i + 3];
            }
        }

        return parseExperssion(expersion);
    }

    function compareAttribute(
        string memory _policyAttrVal,
        string[] memory _attrValue,
        string memory _operator
    ) private pure returns (bool) {
        bool isExistsPolicy = false;

        for (uint256 i = 0; i < _attrValue.length; i++) {
            if (
                stringCompare(_operator, "=") &&
                (stringCompare(_attrValue[i], _policyAttrVal))
            ) {
                isExistsPolicy = true;
                break;
            } else if (
                stringCompare(_operator, "!=") &&
                (!stringCompare(_attrValue[i], _policyAttrVal))
            ) {
                isExistsPolicy = true;
                break;
            } else if (
                stringCompare(_operator, "<") &&
                (stringToUint(_attrValue[i]) <= stringToUint(_policyAttrVal))
            ) {
                isExistsPolicy = true;
                break;
            } else if (
                stringCompare(_operator, ">") &&
                (stringToUint(_attrValue[i]) >= stringToUint(_policyAttrVal))
            ) {
                isExistsPolicy = true;
                break;
            }
        }

        return isExistsPolicy;
    }

    function parseExperssion(string[] memory _expersion)
        private
        pure
        returns (bool)
    {
        bool flag = stringCompare(_expersion[0], "true") ? true : false;

        if (_expersion.length == 1) return flag;

        flag = compareExperssion(_expersion[1], flag, _expersion[2]);

        for (uint256 i = 3; i < _expersion.length; i += 2) {
            if (stringCompare(_expersion[i], "or")) {
                flag = flag || stringCompare(_expersion[i + 1], "true")
                    ? true
                    : false;
            } else if (stringCompare(_expersion[i], "and")) {
                flag = flag && stringCompare(_expersion[i + 1], "true")
                    ? true
                    : false;
            }
        }

        return flag;
    }

    function compareExperssion(
        string memory opt,
        bool val1,
        string memory val2
    ) private pure returns (bool) {
        if (stringCompare(opt, "or")) {
            return val1 || stringCompare(val2, "true") ? true : false;
        } else if (stringCompare(opt, "and")) {
            return val1 && stringCompare(val2, "true") ? true : false;
        }

        return false;
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

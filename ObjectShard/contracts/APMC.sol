// SPDX-License-Identifier:MIT
pragma solidity >=0.4.22 <0.9.0;
 

contract APMC { 

     //variables
    Callee instance;
    mapping(address => mapping(string => PolicyItem[])) internal policies;
    
     constructor( address _OAMC)
     {
          instance=Callee(_OAMC);         
     }

   

     //Struct
    struct PolicyItem {
        string[] attr; //Object attributes
        string action; //Operation
    }

    //add policy for Object
    function addPolicy(        
        address _resource,     //Object Address
        string[] memory _attrs,//Object Attributes
        string memory _action  //Operation
    ) public {         
        policies[_resource][_action].push(PolicyItem(_attrs, _action));        
    } 

    //update policy for Object
    function updatePolicy(        
        address _resource,     //Object Address
        string[] memory _attrs,//Object Attributes
        string memory _action  //Operation
    ) public {         
        policies[_resource][_action].push(PolicyItem(_attrs, _action));        
    } 

     //delete policy for Object
    function deletePolicy(        
        address _resource,     //Object Address       
        string memory _action  //Operation
    ) public {         
       delete policies[_resource][_action];        
    } 

    //check Access control request
    function checkPolicy(
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
            bool isMatchPolicy = findAttr(
                _from,
                policies[_resource][_action][i].attr
            );
            
            if (isMatchPolicy) return (true, firstTime);
        }

        return (false, firstTime);
    }

    function findAttr(address _resource, string[] memory _policyAttr)
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
            attrValue = instance.expand(_resource, _policyAttr[i]);
            bool result = matchAttr(
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

    function matchAttr(
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

interface Callee
{
    function expand(address _address, string memory _attrName)
        external
        view        
        returns (string[] memory _attrValue);
}
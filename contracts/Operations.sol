pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@nomiclabs/buidler/console.sol";

contract Operations is AccessControl{

    IERC20 public token;

    // emitted when operation is added
    event OperationUpdated(bytes4 operation, uint reward);

    event TargetUpdated(address indexed target);

    mapping(address => bool) operationSupported;
    mapping(bytes4 => uint256) rewardPerOperation;


    modifier onlyDefaultAdmin(){
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Operations - not default admin");
        _;
    }

    constructor(address payment_token, address _admin) public {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        token = IERC20(payment_token);
    }


    function callOperation(address _target, bytes4 _operation, bytes calldata _data) public payable returns (bytes memory returnData){
        // check operation is supported
        require(operationSupported[_target] && rewardPerOperation[_operation] > 0 , "Operations - Operation not supported");

        
        bytes memory callData = abi.encodePacked(_operation, _data);
        console.log("here");
        (bool success, bytes memory returnData) = _target.call{value: msg.value}(callData);
        require(success, "Operations - call operation execution failed");
        // finally reward msg.sender in Pool 
        console.log("now rewarding from ", address(this));
        IERC20(token).transfer(msg.sender, rewardPerOperation[_operation]);
        return returnData;
    }

    // add new operations
    function addOrUpdateOperations(bytes4[] calldata operations, uint256[] calldata rewards) public onlyDefaultAdmin {
        // ensure arrays are same size?
        for(uint8 op = 0; op < operations.length; op++){
            rewardPerOperation[operations[op]] = rewards[op];
            emit OperationUpdated(operations[op], rewards[op]);
        }
    }

    function removeOperations(bytes4[] calldata operations) public onlyDefaultAdmin {
        for(uint8 op = 0; op < operations.length; op++ ){
            delete rewardPerOperation[operations[op]];
            emit OperationUpdated(operations[op], 0);
        }
    }

    function addTargets(address[] calldata _targets) public onlyDefaultAdmin {
        for(uint8 target = 0; target < _targets.length; target++ ){
            operationSupported[_targets[target]] = true;
            emit TargetUpdated(_targets[target]);
        }
    }

    function removeTargets(address[] calldata _targets) public onlyDefaultAdmin{
        for(uint8 target = 0; target < _targets.length; target++ ){
            operationSupported[_targets[target]] = false;
            emit TargetUpdated(_targets[target]);
        }
    } 


    // withdraw all balance to specified address
    function withdraw(address destination) public onlyDefaultAdmin {
        IERC20(token).transfer(destination, IERC20(token).balanceOf(address(this)));
    }


    fallback() external payable {
        // no-op
    }

}



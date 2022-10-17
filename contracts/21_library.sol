// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

library Math{
    // 如果function是external/public 在部署Test时, 同时也会单独部署Math合约 在Math.max调用时使用的delegateCall
    // 如果function是internal 在部署时 只需要部署Test即可, 会把Math做为Test的基类 所以使用internal也可以访问它的成员 使用jump命令直接跳转
    function max(uint x, uint y) internal pure returns(uint) {
        return x >= y ? x : y;
    }

}

contract Test{

    function testMax(uint x, uint y) external pure returns(uint) {
        return Math.max(x,y);
    }
}

library ArrayLib{
    // 如果是storage 就不能使用pure修饰, 因为storage引用了存储变量了, 需要使用view
    // 如果要使用pure, 可以用calldata或者memory 这样会把数据拷贝一份到arr中. 这样不会操作存储变量
    function find(uint[] storage arr, uint x) external view returns(uint){
         for(uint i = 0; i < arr.length; i++) {
             if(arr[i] == x){
                 return i;
             }
         }
         revert("not found x");
     }
}

contract TestArray{
    
    // 增加扩展方法
    using ArrayLib for uint[];

    uint[] public arr = [3,2,1];

    function testFind() external view returns(uint){
        // return ArrayLib.find(arr, 2);
        return arr.find(2);
    }

}
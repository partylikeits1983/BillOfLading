// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BillOfLading {

    struct Bill {

        address seller;
        address transport;
        address buyer;

        address token;

        bool status; // bill of lading clean or dirty
        uint quality; // rating 1-5
        string IPFSnotes;

        uint quantity;
        uint value;
        uint weight;
        uint classification;

        uint shipmentDate;
        uint shipmentFee; // percentage

        bool delivered;

    }

    mapping(address => mapping(uint => Bill)) public Bills;
    mapping(address => uint[]) BillID;

    function CreateBill(
        address transport,
        address buyer,
        address token,
        uint quantity,
        uint value,
        uint weight,
        uint shipmentDate,
        uint shipmentFee, // percentage
        uint classification) external returns (uint) {

        uint ID = BillID[msg.sender].length;

        Bills[msg.sender][ID].seller = msg.sender;
        Bills[msg.sender][ID].transport = transport;
        Bills[msg.sender][ID].buyer = buyer;
        Bills[msg.sender][ID].token = token;
        Bills[msg.sender][ID].status = true;
        Bills[msg.sender][ID].quality = 5;
        Bills[msg.sender][ID].quantity = quantity;
        Bills[msg.sender][ID].weight = weight;
        Bills[msg.sender][ID].shipmentDate = shipmentDate;
        Bills[msg.sender][ID].shipmentFee = shipmentFee;
        Bills[msg.sender][ID].classification = classification;

        BillID[msg.sender].push(ID);

        return value;

    }


    function agreeToShipment(address seller, uint ID, address token) public returns (uint) {

        require(Bills[seller][ID].buyer == msg.sender, "User is not buyer set by seller");
        require(Bills[seller][ID].token == token, "Incorrect token address as per contract");

        uint payment = Bills[seller][ID].value;

        IERC20(token).transferFrom(msg.sender, address(this), payment);

        return payment;

    }


    function acceptBillofLading(
        address seller, 
        uint ID, 
        uint quality,
        bool status,
        uint weight,
        uint classification,
        string memory IPFSnotes,
        address token) external returns (uint) {

        require(Bills[seller][ID].transport == msg.sender, "User not designated as transport");
        require(Bills[seller][ID].buyer != address(0), "Buyer not found");

        Bills[seller][ID].status = status;
        Bills[seller][ID].quality = quality;
        Bills[seller][ID].weight = weight;
        Bills[seller][ID].classification = classification;
        Bills[seller][ID].IPFSnotes = IPFSnotes;

        uint amount = Bills[seller][ID].value;
        uint fee = Bills[seller][ID].shipmentFee;
        uint payment = calculatePayment(amount, fee);

        IERC20(token).transfer(msg.sender, payment);

        return payment;

        }


    function updateDelivery(address seller, uint ID) public returns (bool) {

        Bills[seller][ID].delivered = true;

        return true;

    }


    function withdrawFunds(uint ID) public returns (bool) {

        require(Bills[msg.sender][ID].delivered == true, "Goods not delivered");

        uint amount = Bills[msg.sender][ID].value;
        uint fee = Bills[msg.sender][ID].shipmentFee;
        uint transportCost = calculatePayment(amount, fee);

        uint payment = amount - transportCost;

        address token = Bills[msg.sender][ID].token;

        IERC20(token).transfer(msg.sender, payment);

        return true;



    }


    function calculatePayment(uint amount, uint fee) public pure returns (uint) {
        uint payment = fee * 1e18 / amount;

        return payment;

    }


}

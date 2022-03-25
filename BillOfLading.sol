// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract BillOfLading {

    struct {

        address seller;
        address transport;
        address buyer;

        bool status; // bill of lading clean or dirty
        uint quality; // rating 1-5
        string IPFSnotes;

        uint quantity;
        uint value;
        uint weight;

        uint shipmentDate;
        
        uint classification;

    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RentalContract {

    //Property Types
    enum PropertyType { Home, Shop }

    //Tenant Information
    struct Tenant { address tenantAddress; string tenantName; }

    //Owner Information
    struct Owner { address ownerAddress; string ownerName; }

    //Property Information
    struct Property {
        PropertyType propertyType;
        Tenant tenant;
        Owner owner;
    }

    //Lease Information
    struct Lease {
        Property property;
        uint leaseStartDate;
        uint leaseEndDate;
        bool isLeased;
    }

    mapping(address => Property) public properties;
    mapping(address => Lease) public leases;

    event PropertyAdded(address indexed propertyAddress, address ownerAddress, PropertyType propertyType);
    event LeaseStarted(address indexed propertyAddress, address tenantAddress, uint leaseStartDate);
    event LeaseEnded(address indexed propertyAddress, uint leaseEndDate);

    //Property Creation
    function addProperty(address _propertyAddress, string memory _ownerName, PropertyType _propertyType) public {
        require(properties[_propertyAddress].owner.ownerAddress == address(0), "The property already exists.");
        Owner memory newOwner = Owner(msg.sender, _ownerName);
        Property memory newProperty = Property(_propertyType, Tenant(address(0), ""), newOwner);
        properties[_propertyAddress] = newProperty;
        emit PropertyAdded(_propertyAddress, msg.sender, _propertyType);
    }

    //Start Lease
    function startLease(address _propertyAddress, address _tenantAddress, uint _leaseStartDate) public {
        Property storage property = properties[_propertyAddress];
        require(property.owner.ownerAddress == msg.sender, "Only the property owner can start a lease.");
        require(!leases[_propertyAddress].isLeased, "The property is already rented.");
        Lease memory newLease = Lease(property, _leaseStartDate, 0, true);
        leases[_propertyAddress] = newLease;
        emit LeaseStarted(_propertyAddress, _tenantAddress, _leaseStartDate);
    }

    //End Lease
    function endLease(address _propertyAddress, uint _leaseEndDate) public {
        Lease storage lease = leases[_propertyAddress];
        require(lease.property.owner.ownerAddress == msg.sender || lease.property.tenant.tenantAddress == msg.sender, "Only the tenant or the property owner can terminate the lease.");
        require(lease.isLeased, "The property is not rented.");
        lease.leaseEndDate = _leaseEndDate;
        lease.isLeased = false;
        emit LeaseEnded(_propertyAddress, _leaseEndDate);
    }  
     
}






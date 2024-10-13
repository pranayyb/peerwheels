#[test_only]
module MyModule::RideSharing::tests {
    use std::signer;
    use std::vector;
    use MyModule::RideSharing;

    /// This function tests the ride-sharing module.
    public fun test_ride_sharing() {
        // Create a new signer for the rider and driver.
        let rider: signer = signer::create_signer();
        let driver: signer = signer::create_signer();

        // Initialize the ride-sharing module for the rider.
        RideSharing::initialize(&rider);
        
        // Test requesting a ride
        let start_location = vector::from_bytes(b"Location A");
        let end_location = vector::from_bytes(b"Location B");
        let fare = 100;

        // Request a ride
        RideSharing::request_ride(&rider, start_location, end_location, fare);

        // Verify that the ride was created successfully
        let (rider_address, driver_address, start, end, fare_out, status) = RideSharing::get_ride(0);
        assert!(rider_address == signer::address_of(&rider), 1);
        assert!(driver_address == @0x0, 1); // Driver should be unset
        assert!(vector::equal(start, vector::from_bytes(b"Location A")), 1);
        assert!(vector::equal(end, vector::from_bytes(b"Location B")), 1);
        assert!(fare_out == fare, 1);
        assert!(status == RideSharing::STATUS_REQUESTED, 1);

        // Initialize the ride-sharing module for the driver.
        RideSharing::initialize(&driver);

        // Test accepting a ride
        RideSharing::accept_ride(&driver, 0);

        // Verify that the ride status is now accepted
        let (_, driver_address, _, _, _, status) = RideSharing::get_ride(0);
        assert!(driver_address == signer::address_of(&driver), 2);
        assert!(status == RideSharing::STATUS_ACCEPTED, 2);

        // Test completing the ride
        RideSharing::complete_ride(&driver, 0);

        // Verify that the ride status is now completed
        let (_, _, _, _, _, status) = RideSharing::get_ride(0);
        assert!(status == RideSharing::STATUS_COMPLETED, 3);

        // Test cancelling a ride (should fail since it's already completed)
        assert!(assert::failure(RideSharing::cancel_ride(&rider, 0), 4));

        // Test cancelling a ride before completion
        // Recreate the ride
        RideSharing::request_ride(&rider, start_location, end_location, fare);
        RideSharing::accept_ride(&driver, 1);
        RideSharing::cancel_ride(&rider, 1);

        // Verify that the ride status is now cancelled
        let (_, _, _, _, _, status) = RideSharing::get_ride(1);
        assert!(status == RideSharing::STATUS_CANCELLED, 5);
    }
}

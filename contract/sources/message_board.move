// module MyModule::RideSharing {
//     use std::signer;
//     use std::vector;
//     use aptos_framework::timestamp;

//     /// Error codes
//     const E_RIDE_NOT_REQUESTED: u64 = 1;
//     const E_RIDE_NOT_ACCEPTED: u64 = 2;
//     const E_NOT_AUTHORIZED: u64 = 3;

//     struct Ride has store, drop {
//         id: u64,
//         rider: address,
//         driver: address,
//         start_location: vector<u8>,
//         end_location: vector<u8>,
//         fare: u64,
//         status: u8,
//     }

//     struct RideSharingData has key {
//         rides: vector<Ride>,
//         next_ride_id: u64,
//     }

//     const STATUS_REQUESTED: u8 = 0;
//     const STATUS_ACCEPTED: u8 = 1;
//     const STATUS_COMPLETED: u8 = 2;
//     const STATUS_CANCELLED: u8 = 3;

//     public entry fun initialize(owner: &signer) {
//         let ride_sharing_data = RideSharingData {
//             rides: vector::empty<Ride>(),
//             next_ride_id: 0,
//         };
//         move_to(owner, ride_sharing_data);
//     }

//     public entry fun request_ride(
//         rider: &signer,
//         start_location: vector<u8>,
//         end_location: vector<u8>,
//         fare: u64
//     ) acquires RideSharingData {
//         let ride_sharing_data = borrow_global_mut<RideSharingData>(@MyModule);
//         let ride_id = ride_sharing_data.next_ride_id;
//         let ride = Ride {
//             id: ride_id,
//             rider: signer::address_of(rider),
//             driver: @0x0,
//             start_location,
//             end_location,
//             fare,
//             status: STATUS_REQUESTED,
//         };
//         vector::push_back(&mut ride_sharing_data.rides, ride);
//         ride_sharing_data.next_ride_id = ride_id + 1;
//     }

//     public entry fun accept_ride(driver: &signer, ride_id: u64) acquires RideSharingData {
//         let ride_sharing_data = borrow_global_mut<RideSharingData>(@MyModule);
//         let ride = vector::borrow_mut(&mut ride_sharing_data.rides, ride_id);
//         assert!(ride.status == STATUS_REQUESTED, E_RIDE_NOT_REQUESTED);
//         ride.driver = signer::address_of(driver);
//         ride.status = STATUS_ACCEPTED;
//     }

//     public entry fun complete_ride(driver: &signer, ride_id: u64) acquires RideSharingData {
//         let ride_sharing_data = borrow_global_mut<RideSharingData>(@MyModule);
//         let ride = vector::borrow_mut(&mut ride_sharing_data.rides, ride_id);
//         assert!(ride.status == STATUS_ACCEPTED, E_RIDE_NOT_ACCEPTED);
//         assert!(ride.driver == signer::address_of(driver), E_NOT_AUTHORIZED);
//         ride.status = STATUS_COMPLETED;
//     }

//     public entry fun cancel_ride(rider: &signer, ride_id: u64) acquires RideSharingData {
//         let ride_sharing_data = borrow_global_mut<RideSharingData>(@MyModule);
//         let ride = vector::borrow_mut(&mut ride_sharing_data.rides, ride_id);
//         assert!(ride.status == STATUS_REQUESTED, E_RIDE_NOT_REQUESTED);
//         assert!(ride.rider == signer::address_of(rider), E_NOT_AUTHORIZED);
//         ride.status = STATUS_CANCELLED;
//     }

//     #[view]
//     public fun get_ride(ride_id: u64): (address, address, vector<u8>, vector<u8>, u64, u8) acquires RideSharingData {
//         let ride_sharing_data = borrow_global<RideSharingData>(@MyModule);
//         let ride = vector::borrow(&ride_sharing_data.rides, ride_id);
//         (
//             ride.rider,
//             ride.driver,
//             *&ride.start_location,
//             *&ride.end_location,
//             ride.fare,
//             ride.status
//         )
//     }
// }



module MyModule::RideSharingV2 {
    use std::signer;
    use std::vector;
    use aptos_framework::timestamp;

    /// Error codes
    const E_RIDE_NOT_REQUESTED: u64 = 1;
    const E_RIDE_NOT_ACCEPTED: u64 = 2;
    const E_NOT_AUTHORIZED: u64 = 3;
    const E_ALREADY_INITIALIZED: u64 = 4;

    struct Ride has store, drop {
        id: u64,
        rider: address,
        driver: address,
        start_location: vector<u8>,
        end_location: vector<u8>,
        fare: u64,
        status: u8,
    }

    struct RideSharingData has key {
        rides: vector<Ride>,
        next_ride_id: u64,
    }

    const STATUS_REQUESTED: u8 = 0;
    const STATUS_ACCEPTED: u8 = 1;
    const STATUS_COMPLETED: u8 = 2;
    const STATUS_CANCELLED: u8 = 3;

    // public entry fun initialize(owner: &signer) {
    //     let ride_sharing_data = RideSharingData {
    //         rides: vector::empty<Ride>(),
    //         next_ride_id: 0,
    //     };
    //     move_to(owner, ride_sharing_data);
    // }

    public entry fun initialize(owner: &signer) {
        // assert!(!exists<RideSharingData>(signer::address_of(owner)), E_ALREADY_INITIALIZED);
        
        let rides = vector::empty<Ride>();
        // rides: vector::empty<Ride>();
        // let ride_sharing_data = RideSharingData {
        //         rides: vector::empty<Ride>(),
        //         next_ride_id: 0,
        //     };

        // Prepopulate with 5 default rides
        let default_ride_1 = Ride {
            id: 0,
            rider: @0x123, // example rider address
            driver: @0x0,  // no driver assigned
            start_location: b"Location A",
            end_location: b"Location B",
            fare: 100,
            status: STATUS_REQUESTED,
        };
        
        let default_ride_2 = Ride {
            id: 1,
            rider: @0x124,
            driver: @0x0,
            start_location: b"Location C",
            end_location: b"Location D",
            fare: 150,
            status: STATUS_REQUESTED,
        };

        let default_ride_3 = Ride {
            id: 2,
            rider: @0x125,
            driver: @0x0,
            start_location: b"Location E",
            end_location: b"Location F",
            fare: 200,
            status: STATUS_REQUESTED,
        };

        let default_ride_4 = Ride {
            id: 3,
            rider: @0x126,
            driver: @0x0,
            start_location: b"Location G",
            end_location: b"Location H",
            fare: 120,
            status: STATUS_REQUESTED,
        };

        let default_ride_5 = Ride {
            id: 4,
            rider: @0x127,
            driver: @0x0,
            start_location: b"Location I",
            end_location: b"Location J",
            fare: 80,
            status: STATUS_REQUESTED,
        };

        // Push the 5 rides into the vector
        vector::push_back(&mut rides, default_ride_1);
        vector::push_back(&mut rides, default_ride_2);
        vector::push_back(&mut rides, default_ride_3);
        vector::push_back(&mut rides, default_ride_4);
        vector::push_back(&mut rides, default_ride_5);

        let ride_sharing_data = RideSharingData {
            rides,
            next_ride_id: 5, // Next ride ID after the 5 prepopulated rides
        };

        move_to(owner, ride_sharing_data);
    }


    public entry fun request_ride(
        rider: &signer,
        start_location: vector<u8>,
        end_location: vector<u8>,
        fare: u64
    ) acquires RideSharingData {
        let ride_sharing_data = borrow_global_mut<RideSharingData>(@MyModule);
        let ride_id = ride_sharing_data.next_ride_id;
        let ride = Ride {
            id: ride_id,
            rider: signer::address_of(rider),
            driver: @0x0,
            start_location,
            end_location,
            fare,
            status: STATUS_REQUESTED,
        };
        vector::push_back(&mut ride_sharing_data.rides, ride);
        ride_sharing_data.next_ride_id = ride_id + 1;
    }

    public entry fun accept_ride(driver: &signer, ride_id: u64) acquires RideSharingData {
        let ride_sharing_data = borrow_global_mut<RideSharingData>(@MyModule);
        let ride = vector::borrow_mut(&mut ride_sharing_data.rides, ride_id);
        assert!(ride.status == STATUS_REQUESTED, E_RIDE_NOT_REQUESTED);
        ride.driver = signer::address_of(driver);
        ride.status = STATUS_ACCEPTED;
    }

    public entry fun complete_ride(driver: &signer, ride_id: u64) acquires RideSharingData {
        let ride_sharing_data = borrow_global_mut<RideSharingData>(@MyModule);
        let ride = vector::borrow_mut(&mut ride_sharing_data.rides, ride_id);
        assert!(ride.status == STATUS_ACCEPTED, E_RIDE_NOT_ACCEPTED);
        assert!(ride.driver == signer::address_of(driver), E_NOT_AUTHORIZED);
        ride.status = STATUS_COMPLETED;
    }

    public entry fun cancel_ride(rider: &signer, ride_id: u64) acquires RideSharingData {
        let ride_sharing_data = borrow_global_mut<RideSharingData>(@MyModule);
        let ride = vector::borrow_mut(&mut ride_sharing_data.rides, ride_id);
        assert!(ride.status == STATUS_REQUESTED, E_RIDE_NOT_REQUESTED);
        assert!(ride.rider == signer::address_of(rider), E_NOT_AUTHORIZED);
        ride.status = STATUS_CANCELLED;
    }

    #[view]
    public fun get_ride(ride_id: u64): (address, address, vector<u8>, vector<u8>, u64, u8) acquires RideSharingData {
        let ride_sharing_data = borrow_global<RideSharingData>(@MyModule);
        let ride = vector::borrow(&ride_sharing_data.rides, ride_id);
        (
            ride.rider,
            ride.driver,
            *&ride.start_location,
            *&ride.end_location,
            ride.fare,
            ride.status
        )
    }
}

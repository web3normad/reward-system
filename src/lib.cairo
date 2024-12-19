use starknet::ContractAddress;

#[starknet::interface]
trait IRewardPoints<TContractState> {
    fn add_points(ref self: TContractState, user: ContractAddress, points: u256);
    fn redeem_points(ref self: TContractState, user: ContractAddress, points: u256);
    fn get_user_points(self: @TContractState, user: ContractAddress) -> u256;
}

#[starknet::contract]
mod RewardPointsContract {
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        user_points: LegacyMap::<ContractAddress, u256>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        PointsAdded: PointsAdded,
        PointsRedeemed: PointsRedeemed
    }

    #[derive(Drop, starknet::Event)]
    struct PointsAdded {
        #[key]
        user: ContractAddress,
        points: u256
    }

    #[derive(Drop, starknet::Event)]
    struct PointsRedeemed {
        #[key]
        user: ContractAddress,
        points: u256
    }

    #[abi(embed_v0)]
    impl RewardPointsImpl of super::IRewardPoints<ContractState> {
        fn add_points(ref self: ContractState, user: ContractAddress, points: u256) {
            let current_points = self.user_points.read(user);
            let new_points = current_points + points;
            self.user_points.write(user, new_points);
            
            self.emit(Event::PointsAdded(PointsAdded { user, points }));
        }

        fn redeem_points(ref self: ContractState, user: ContractAddress, points: u256) {
            let current_points = self.user_points.read(user);
            assert(current_points >= points, 'Not enough points');
            
            let new_points = current_points - points;
            self.user_points.write(user, new_points);
            
            self.emit(Event::PointsRedeemed(PointsRedeemed { user, points }));
        }

        fn get_user_points(self: @ContractState, user: ContractAddress) -> u256 {
            self.user_points.read(user)
        }
    }
}
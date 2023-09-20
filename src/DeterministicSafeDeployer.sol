// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IProxyFactory {
    function proxyCreationCode() external pure returns (bytes memory);

    function createProxyWithNonce(
        address _singleton,
        bytes memory initializer,
        uint256 saltNonce
    ) external returns (address);
}

contract DeterministicSafeDeployer {
    address public constant SAFE_PROXY_FACTORY =
        0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;

    address public constant SAFE_SINGLETON =
        0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;

    address public constant SAFE_FALLBACK_HANDLER =
        0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4;

    function deploySafe(address owner, uint256 nonce) public {
        bytes memory initializer = getInitializationParams(owner);

        IProxyFactory(SAFE_PROXY_FACTORY).createProxyWithNonce(
            SAFE_SINGLETON,
            initializer,
            nonce
        );
    }

    function getSafeAddress(
        address owner,
        uint256 nonce
    ) public pure returns (address) {
        bytes memory initializer = getInitializationParams(owner);
        bytes32 salt = keccak256(
            abi.encodePacked(keccak256(initializer), nonce)
        );

        return predictDeterministicAddress(salt);
    }

    function predictDeterministicAddress(
        bytes32 salt
    ) private pure returns (address predicted) {
        bytes memory creationCode = IProxyFactory(SAFE_PROXY_FACTORY)
            .proxyCreationCode();

        bytes32 hash = keccak256(
            abi.encodePacked(creationCode, uint256(uint160(SAFE_SINGLETON)))
        );
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and store the bytecode hash.
            mstore8(0x00, 0xff) // Write the prefix.
            mstore(0x35, hash)
            mstore(0x01, shl(96, SAFE_PROXY_FACTORY))
            mstore(0x15, salt)
            predicted := keccak256(0x00, 0x55)
            // Restore the part of the free memory pointer that has been overwritten.
            mstore(0x35, 0)
        }
    }

    function getInitializationParams(
        address owner
    ) private pure returns (bytes memory) {
        address[] memory _owners = new address[](1);
        _owners[0] = owner;

        return
            abi.encodeWithSignature(
                "setup(address[],uint256,address,bytes,address,address,uint256,address)",
                _owners,
                1,
                address(0),
                "",
                SAFE_FALLBACK_HANDLER,
                address(0),
                0,
                address(0)
            );
    }
}

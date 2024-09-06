//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";

contract Review {
    ISemaphore public semaphore;

    uint256 public reviewerGroupId;

    uint256 public ownerGroupId;

    uint256[] posts;

    mapping(uint256 => uint256[]) public comments;

    constructor(address semaphoreAddress) {
        semaphore = ISemaphore(semaphoreAddress);

        reviewerGroupId = semaphore.createGroup();
        ownerGroupId = semaphore.createGroup();
    }

    function joinReviewerGroup(uint256 identityCommitment, uint256 r, uint256 s) external {
        semaphore.addMember(reviewerGroupId, identityCommitment);
    }

    function joinOwnerGroup(uint256 identityCommitment) external {
        semaphore.addMember(ownerGroupId, identityCommitment);
    }

    function getPosts() public view returns (uint256[] memory) {
        return posts;
    }

    function sendPost(
        uint256 merkleTreeDepth,
        uint256 merkleTreeRoot,
        uint256 nullifier,
        uint256 review,
        uint256 reviewerId,
        uint256[8] calldata points
    ) external {
        ISemaphore.SemaphoreProof memory proof = ISemaphore.SemaphoreProof(
            merkleTreeDepth,
            merkleTreeRoot,
            nullifier,
            review,
            reviewerId,
            points
        );

        semaphore.validateProof(reviewerGroupId, proof);
        posts.push(review);
        comments[review];
    }

    function getComments(uint256 key) public view returns (uint256[] memory) {
        return comments[key];
    }

    function sendComment(
        uint256 merkleTreeDepth,
        uint256 merkleTreeRoot,
        uint256 nullifier,
        uint256 comment,
        uint256[8] calldata points,
        uint256 review
    ) external {
        ISemaphore.SemaphoreProof memory proof = ISemaphore.SemaphoreProof(
            merkleTreeDepth,
            merkleTreeRoot,
            nullifier,
            comment,
            reviewerGroupId,
            points
        );

        semaphore.validateProof(reviewerGroupId, proof);
        comments[review].push(comment);
    }
}

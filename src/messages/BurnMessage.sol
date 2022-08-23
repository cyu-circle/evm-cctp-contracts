/* SPDX-License-Identifier: UNLICENSED
 *
 * Copyright (c) 2022, Circle Internet Financial Trading Company Limited.
 * All rights reserved.
 *
 * Circle Internet Financial Trading Company Limited CONFIDENTIAL
 *
 * This file includes unpublished proprietary source code of Circle Internet
 * Financial Trading Company Limited, Inc. The copyright notice above does not
 * evidence any actual or intended publication of such source code. Disclosure
 * of this source code or any related proprietary information is strictly
 * prohibited without the express written permission of Circle Internet Financial
 * Trading Company Limited.
 */
pragma solidity ^0.7.6;

import "@memview-sol/contracts/TypedMemView.sol";

/**
 * @title BurnMessage Library
 * @notice Library for formatted BurnMessages used by CircleBridge.
 * @dev BurnMessage format:
 * Field                 Bytes      Type       Index
 * version               4          uint8      0
 * burnToken             32         bytes32    4
 * mintRecipient         32         bytes32    36
 * amount                32         uint256    68
 **/
library BurnMessage {
    using TypedMemView for bytes;
    using TypedMemView for bytes29;

    uint8 private constant VERSION_INDEX = 0;
    uint8 private constant VERSION_LEN = 4;
    uint8 private constant BURN_TOKEN_INDEX = 4;
    uint8 private constant BURN_TOKEN_LEN = 32;
    uint8 private constant MINT_RECIPIENT_INDEX = 36;
    uint8 private constant MINT_RECIPIENT_LEN = 32;
    uint8 private constant AMOUNT_INDEX = 68;
    uint8 private constant AMOUNT_LEN = 32;
    // 4 byte version + 32 bytes burnToken + 32 bytes mintRecipient + 32 bytes amount
    uint8 private constant BURN_MESSAGE_LEN = 100;

    /**
     * @notice Formats Burn message
     * @param _version The message body version
     * @param _burnToken The burn token address on source domain as bytes32
     * @param _mintRecipient The mint recipient address as bytes32
     * @param _amount The burn amount
     * @return Burn formatted message.
     */
    function formatMessage(
        uint32 _version,
        bytes32 _burnToken,
        bytes32 _mintRecipient,
        uint256 _amount
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(_version, _burnToken, _mintRecipient, _amount);
    }

    /**
     * @notice Retrieves the burnToken from a DepositForBurn BurnMessage
     * @param _message The message
     * @return sourceToken address as bytes32
     */
    function getBurnToken(bytes29 _message) internal pure returns (bytes32) {
        return _message.index(BURN_TOKEN_INDEX, BURN_TOKEN_LEN);
    }

    /**
     * @notice Retrieves the mintRecipient from a BurnMessage
     * @param _message The message
     * @return mintRecipient
     */
    function getMintRecipient(bytes29 _message)
        internal
        pure
        returns (bytes32)
    {
        return _message.index(MINT_RECIPIENT_INDEX, MINT_RECIPIENT_LEN);
    }

    /**
     * @notice Retrieves the amount from a BurnMessage
     * @param _message The message
     * @return amount
     */
    function getAmount(bytes29 _message) internal pure returns (uint256) {
        return _message.indexUint(AMOUNT_INDEX, AMOUNT_LEN);
    }

    /**
     * @notice Retrieves the version from a Burn message
     * @param _message The message
     * @return version
     */
    function getVersion(bytes29 _message) internal pure returns (uint32) {
        return uint32(_message.indexUint(VERSION_INDEX, 4));
    }

    /**
     * @notice Checks that view is a valid message length
     * @param _message The bytes string
     * @return true if message is correct length and version for a burn message
     */
    function isValidBurnMessage(bytes29 _message, uint32 _version)
        internal
        pure
        returns (bool)
    {
        uint256 _len = _message.len();
        return _len == BURN_MESSAGE_LEN && _version == getVersion(_message);
    }
}
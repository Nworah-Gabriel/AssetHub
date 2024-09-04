// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title RealWorldLending
 * @dev Contract for real-world lending and borrowing using ERC20 tokens as collateral.
 */
contract RealWorldLending is ReentrancyGuard {
    struct Loan {
        address borrower;
        address lender;
        uint256 amount;
        uint256 collateral;
        uint256 interestRate;
        uint256 duration;
        bool repaid;
    }

    IERC20 public realixToken;
    uint256 public loanIdCounter;
    mapping(uint256 => Loan) public loans;

    /**
     * @notice Constructor to initialize the RealWorldLending contract.
     * @param _realixToken The address of the Realix ERC20 token.
     */
    constructor(IERC20 _realixToken)payable {
        realixToken = _realixToken;
    }

    /**
     * @notice Request a loan with collateral.
     * @param amount The loan amount in RLX tokens.
     * @param collateral The amount of collateral in RLX tokens.
     * @param interestRate The interest rate for the loan.
     * @param duration The duration of the loan in seconds.
     * @return The loan ID.
     */
    function requestLoan(uint256 amount, uint256 collateral, uint256 interestRate, uint256 duration) public nonReentrant returns (uint256) {
        require(realixToken.transferFrom(msg.sender, address(this), collateral), "Collateral transfer failed");
        loanIdCounter++;
        loans[loanIdCounter] = Loan({
            borrower: msg.sender,
            lender: address(0),
            amount: amount,
            collateral: collateral,
            interestRate: interestRate,
            duration: duration,
            repaid: false
        });
        return loanIdCounter;
    }

    /**
     * @notice Lend RLX tokens to a borrower.
     * @param loanId The ID of the loan.
     */
    function lend(uint256 loanId) public nonReentrant {
        Loan storage loan = loans[loanId];
        require(loan.lender == address(0), "Loan already funded");
        require(realixToken.transferFrom(msg.sender, loan.borrower, loan.amount), "Loan transfer failed");
        loan.lender = msg.sender;
    }

    /**
     * @notice Repay the loan and retrieve collateral.
     * @param loanId The ID of the loan.
     */
    function repayLoan(uint256 loanId) public nonReentrant {
        Loan storage loan = loans[loanId];
        require(msg.sender == loan.borrower, "Only borrower can repay the loan");
        require(!loan.repaid, "Loan already repaid");

        uint256 repaymentAmount = loan.amount + (loan.amount * loan.interestRate / 100);
        require(realixToken.transferFrom(msg.sender, loan.lender, repaymentAmount), "Repayment transfer failed");
        require(realixToken.transfer(msg.sender, loan.collateral), "Collateral return failed");

        loan.repaid = true;
    }

    /**
     * @notice Claim collateral if the loan is not repaid on time.
     * @param loanId The ID of the loan.
     */
    function claimCollateral(uint256 loanId) public nonReentrant {
        Loan storage loan = loans[loanId];
        require(msg.sender == loan.lender, "Only lender can claim collateral");
        require(!loan.repaid, "Loan already repaid");
        require(block.timestamp > loan.duration, "Loan duration not yet passed");

        require(realixToken.transfer(msg.sender, loan.collateral), "Collateral claim failed");
    }
}

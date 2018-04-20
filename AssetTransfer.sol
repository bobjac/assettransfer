pragma solidity ^0.4.10;

contract AppBuilderBase {
    event AppBuilderContractCreated(string contractType, address originatingAddress);
    event AppBuilderContractUpdated(string contractType, string action, address originatingAddress);
    
    string internal ContractType;

    function AppBuilderBase(string contractType) internal {
        ContractType = contractType;
    }

    function ContractCreated() internal {
        AppBuilderContractCreated(ContractType, msg.sender);
    }

    function ContractUpdated(string action) internal {
        AppBuilderContractUpdated(ContractType, action, msg.sender);
    }
}

contract AssetTransfer is AppBuilderBase('AssetTransfer')
{
    enum AssetState { Created, Active, OfferPlaced, PendingInspection, Inspected, Appraised, NotionalAcceptance, BuyerAccepted, SellerAccepted, Accepted, Complete, Terminated }
    address public Owner;
    string public Description;
    uint public AskingPrice;
    AssetState public State;
    
    address public Buyer;
    uint public OfferPrice;
    address public Inspector;
    address public Appraiser;
    
    function AssetTransfer(string description, uint256 price) 
    {
        Owner = msg.sender;
        AskingPrice = price;
        Description = description;
        State = AssetState.Active;
        ContractCreated();
    }
	
	function Terminate()
	{
        if (Owner != msg.sender)
        {
            revert();
        }
		
        State = AssetState.Terminated;
        ContractUpdated('Terminate');
	}

    function Modify(string description, uint256 price)
    {
        if (Owner != msg.sender)
        {
            revert();
        }

        Description = description;
        AskingPrice = price;
        ContractUpdated('Modify');
    }

    function MakeOffer(address inspector, address appraiser, uint256 offerPrice)
    {
        if (inspector == 0x0 || appraiser == 0x0 || offerPrice == 0)
        {
            revert();
        }

        if (Buyer != 0x0 || Owner == msg.sender)
        {
            revert();
        }
        
        Buyer = msg.sender;
        Inspector = inspector;
        Appraiser = appraiser;
        OfferPrice = offerPrice;
        State = AssetState.OfferPlaced;
        ContractUpdated('MakeOffer');
    }

    function AcceptOffer()
    {
        if (Owner != msg.sender || State != AssetState.OfferPlaced)
        {
            revert();
        }

        State = AssetState.PendingInspection;
        ContractUpdated('AcceptOffer');
    }
	
	function Reject()
	{
        if (Owner != msg.sender)
        {
            revert();
        }
		
        Buyer = 0x0;
		State = AssetState.Active;
        ContractUpdated('Reject');
	}
	
	function Accept()
	{
		if (msg.sender != Buyer && msg.sender != Owner)
		{
			revert();
		}
		
		if (State != AssetState.NotionalAcceptance && 
			State != AssetState.BuyerAccepted &&
			State != AssetState.SellerAccepted)
		{
			revert();
		}
		
		if (msg.sender == Buyer)
		{
			if (State == AssetState.NotionalAcceptance)
			{
				State = AssetState.BuyerAccepted;
			}
			else if (State == AssetState.SellerAccepted)
			{
				State = AssetState.Accepted;
			}
		}
		else 
		{
			if (State == AssetState.NotionalAcceptance)
			{
				State = AssetState.SellerAccepted;
			}
			else if (State == AssetState.BuyerAccepted)
			{
				State = AssetState.Accepted;
			}
		}
        ContractUpdated('Accept');
	}

    function ModifyOffer(uint256 offerPrice)
    {
        if (Buyer != msg.sender || offerPrice == 0)
        {
            revert();
        }

        OfferPrice = offerPrice;
        ContractUpdated('ModifyOffer');
    }
    
    function RescindOffer()
    {
        if (Buyer != msg.sender)
        {
            revert();
        }

        Buyer = 0x0;
        OfferPrice = 0;
        State = AssetState.Active;
        ContractUpdated('RescindOffer');
    }

    function MarkAppraised()
    {
        if (Appraiser != msg.sender)
        {
            revert();
        }

        if (State == AssetState.PendingInspection)
        {
            State = AssetState.Appraised;
        }
        else if (State == AssetState.Inspected)
        {
            State = AssetState.NotionalAcceptance;
        }
        ContractUpdated('MarkAppraised');
    }

    function MarkInspected()
    {
        if (Inspector != msg.sender)
        {
            revert();
        }

        if (State == AssetState.PendingInspection)
        {
            State = AssetState.Inspected;
        }
        else if (State == AssetState.Appraised)
        {
            State = AssetState.NotionalAcceptance;
        }
        ContractUpdated('MarkInspected');
    }
}

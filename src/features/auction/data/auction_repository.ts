import { defaultApiClient, ApiClient } from '../../../core/network/api_client';
import { BidRecord } from '../../../core/types';
import { INITIAL_BID_HISTORY } from '../../../core/storage/marketplace_store';

export class AuctionRepository {
  private client: ApiClient;

  constructor(client: ApiClient = defaultApiClient) {
    this.client = client;
  }

  public async getBidHistory(auctionId: string): Promise<BidRecord[]> {
    const res = await this.client.get<BidRecord[]>(`/auctions/${auctionId}/bids`, () => INITIAL_BID_HISTORY);
    return res.data;
  }

  public async placeBid(auctionId: string, amount: number, bidderName: string): Promise<{ success: boolean; newBid: BidRecord }> {
    const res = await this.client.post<{ success: boolean; newBid: BidRecord }>(`/auctions/${auctionId}/bid`, { amount }, () => {
      const newBid: BidRecord = {
        id: `bid-${Date.now()}`,
        bidder: bidderName,
        avatarLetter: bidderName.charAt(0).toUpperCase() || 'U',
        amount,
        timestamp: 'Just now',
        isUser: true
      };
      return { success: true, newBid };
    });
    return res.data;
  }
}

export const auctionRepository = new AuctionRepository();

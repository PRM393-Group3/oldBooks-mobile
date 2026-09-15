import { defaultApiClient, ApiClient } from '../../../core/network/api_client';
import { BookItem } from '../../../core/types';
import { INITIAL_AUCTIONS, INITIAL_RECOMMENDED_BOOKS } from '../../../core/storage/marketplace_store';

export class MarketplaceRepository {
  private client: ApiClient;

  constructor(client: ApiClient = defaultApiClient) {
    this.client = client;
  }

  public async getRecommendedBooks(): Promise<BookItem[]> {
    const res = await this.client.get<BookItem[]>('/marketplace/recommended', () => INITIAL_RECOMMENDED_BOOKS);
    return res.data;
  }

  public async getLiveAuctions(): Promise<BookItem[]> {
    const res = await this.client.get<BookItem[]>('/marketplace/live-auctions', () => INITIAL_AUCTIONS);
    return res.data;
  }
}

export const marketplaceRepository = new MarketplaceRepository();

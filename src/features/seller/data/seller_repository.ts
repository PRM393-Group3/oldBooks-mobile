import { defaultApiClient, ApiClient } from '../../../core/network/api_client';
import { SellerListing } from '../../../core/types';
import { INITIAL_SELLER_LISTINGS } from '../../../core/storage/marketplace_store';

export class SellerRepository {
  private client: ApiClient;

  constructor(client: ApiClient = defaultApiClient) {
    this.client = client;
  }

  public async getListings(): Promise<SellerListing[]> {
    const res = await this.client.get<SellerListing[]>('/seller/listings', () => INITIAL_SELLER_LISTINGS);
    return res.data;
  }

  public async createListing(listingData: Partial<SellerListing>): Promise<SellerListing> {
    const res = await this.client.post<SellerListing>('/seller/listings', listingData, () => {
      return {
        id: `listing-${Date.now()}`,
        title: listingData.title || 'Untitled Book',
        author: listingData.author || 'Unknown Author',
        edition: listingData.edition || '1st Edition',
        format: listingData.format || 'Paperback',
        price: listingData.price || 25.00,
        priceType: listingData.priceType || 'Live Auction',
        status: 'WAITING FOR INSPECTOR APPROVAL',
        coverImage: listingData.coverImage || 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
        timeAgo: 'Just now',
        extraInfo: 'Queue Position: #4 in Brooklyn'
      };
    });
    return res.data;
  }
}

export const sellerRepository = new SellerRepository();

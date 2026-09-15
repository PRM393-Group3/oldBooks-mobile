import { defaultApiClient, ApiClient } from '../../../core/network/api_client';
import { CartItem } from '../../../core/types';
import { INITIAL_CART } from '../../../core/storage/marketplace_store';

export class CartRepository {
  private client: ApiClient;

  constructor(client: ApiClient = defaultApiClient) {
    this.client = client;
  }

  public async getCart(): Promise<CartItem[]> {
    const res = await this.client.get<CartItem[]>('/cart', () => INITIAL_CART);
    return res.data;
  }

  public async placeOrder(orderDetails: any): Promise<{ orderId: string; status: string }> {
    const res = await this.client.post<{ orderId: string; status: string }>('/checkout/place-order', orderDetails, () => ({
      orderId: 'BK-9082',
      status: 'Escrow Secured'
    }));
    return res.data;
  }
}

export const cartRepository = new CartRepository();

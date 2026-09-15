import { defaultApiClient, ApiClient } from '../../../core/network/api_client';

export interface OrderTrackingDetails {
  orderId: string;
  status: string;
  estimatedDelivery: string;
  escrowAmount: number;
  carrier: string;
  trackingNumber: string;
  lastCheckpoint: string;
  currentStep: number;
}

export class OrderRepository {
  private client: ApiClient;

  constructor(client: ApiClient = defaultApiClient) {
    this.client = client;
  }

  public async getOrderTracking(orderId: string): Promise<OrderTrackingDetails> {
    const res = await this.client.get<OrderTrackingDetails>(`/orders/${orderId}/tracking`, () => ({
      orderId,
      status: 'In Transit - Shipped via Media Mail',
      estimatedDelivery: 'Tomorrow, Oct 24 by 4:00 PM',
      escrowAmount: 46.50,
      carrier: 'USPS Priority Media Mail',
      trackingNumber: '9400 1000 8921 4452 10',
      lastCheckpoint: 'Jersey City Sorting Facility',
      currentStep: 3
    }));
    return res.data;
  }
}

export const orderRepository = new OrderRepository();

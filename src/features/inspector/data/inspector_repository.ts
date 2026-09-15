import { defaultApiClient, ApiClient } from '../../../core/network/api_client';
import { InspectionCheckItem } from '../../../core/types';
import { INITIAL_CHECKLIST } from '../../../core/storage/marketplace_store';

export class InspectorRepository {
  private client: ApiClient;

  constructor(client: ApiClient = defaultApiClient) {
    this.client = client;
  }

  public async getChecklist(): Promise<InspectionCheckItem[]> {
    const res = await this.client.get<InspectionCheckItem[]>('/inspector/checklist', () => INITIAL_CHECKLIST);
    return res.data;
  }

  public async approveListing(bookId: string): Promise<{ success: boolean; certificateId: string }> {
    const res = await this.client.post<{ success: boolean; certificateId: string }>(`/inspector/${bookId}/approve`, {}, () => ({
      success: true,
      certificateId: `#BK-${Math.floor(10000 + Math.random() * 90000)}-DX`
    }));
    return res.data;
  }

  public async rejectListing(bookId: string, reason: string, notes: string): Promise<{ success: boolean; status: string }> {
    const res = await this.client.post<{ success: boolean; status: string }>(`/inspector/${bookId}/reject`, { reason, notes }, () => ({
      success: true,
      status: 'Moved to Remediation Queue'
    }));
    return res.data;
  }
}

export const inspectorRepository = new InspectorRepository();

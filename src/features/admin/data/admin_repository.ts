import { defaultApiClient, ApiClient } from '../../../core/network/api_client';
import { DisputeCase, UserReputation, InspectorLedgerEntry } from '../../../core/types';
import { INITIAL_DISPUTES, INITIAL_USERS, INITIAL_LEDGER } from '../../../core/storage/marketplace_store';

export class AdminRepository {
  private client: ApiClient;

  constructor(client: ApiClient = defaultApiClient) {
    this.client = client;
  }

  public async getDisputes(): Promise<DisputeCase[]> {
    const res = await this.client.get<DisputeCase[]>('/admin/disputes', () => INITIAL_DISPUTES);
    return res.data;
  }

  public async getUsers(): Promise<UserReputation[]> {
    const res = await this.client.get<UserReputation[]>('/admin/users', () => INITIAL_USERS);
    return res.data;
  }

  public async getLedgerStream(): Promise<InspectorLedgerEntry[]> {
    const res = await this.client.get<InspectorLedgerEntry[]>('/admin/ledger-stream', () => INITIAL_LEDGER);
    return res.data;
  }

  public async freezeEscrow(disputeId: string): Promise<boolean> {
    const res = await this.client.patch<{ frozen: boolean }>(`/admin/disputes/${disputeId}/freeze`, {}, () => ({ frozen: true }));
    return res.data.frozen;
  }
}

export const adminRepository = new AdminRepository();

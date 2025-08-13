import { Order } from './order.entity';
export declare class Payment {
    id: number;
    orderId: string;
    paymentMethod: string;
    status: string;
    paidAt: Date;
    order: Order;
}

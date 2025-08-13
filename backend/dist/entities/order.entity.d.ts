import { User } from './user.entity';
import { OrderItem } from './order-item.entity';
import { Payment } from './payment.entity';
export declare class Order {
    id: string;
    userId: string;
    status: string;
    total: number;
    createdAt: Date;
    user: User;
    items: OrderItem[];
    payments: Payment[];
}

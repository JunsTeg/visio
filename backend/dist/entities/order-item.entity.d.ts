import { Order } from './order.entity';
import { Product } from './product.entity';
export declare class OrderItem {
    id: number;
    orderId: string;
    productId: string;
    quantity: number;
    unitPrice: number;
    order: Order;
    product: Product;
}

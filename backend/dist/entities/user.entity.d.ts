import { Role } from './role.entity';
import { Product } from './product.entity';
import { Order } from './order.entity';
export declare class User {
    id: string;
    fullName: string;
    email: string;
    phoneNumber: string;
    passwordHash: string;
    avatarUrl: string;
    isVerified: boolean;
    lastLogin: Date;
    active: boolean;
    online: boolean;
    createdAt: Date;
    roles: Role[];
    products: Product[];
    orders: Order[];
}

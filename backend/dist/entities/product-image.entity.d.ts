import { Product } from './product.entity';
export declare class ProductImage {
    id: number;
    productId: string;
    imageUrl: string;
    isPrimary: boolean;
    product: Product;
}

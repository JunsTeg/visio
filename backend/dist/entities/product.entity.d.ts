import { User } from './user.entity';
import { Category } from './category.entity';
import { ProductImage } from './product-image.entity';
import { ProductModel } from './product-model.entity';
export declare class Product {
    id: string;
    name: string;
    description: string;
    price: number;
    stock: number;
    categoryId: number;
    sellerId: string;
    thumbnailUrl: string;
    createdAt: Date;
    category: Category;
    seller: User;
    images: ProductImage[];
    models: ProductModel[];
}

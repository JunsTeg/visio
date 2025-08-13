import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Product } from './product.entity';

@Entity('product_models')
export class ProductModel {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'product_id' })
  productId: string;

  @Column({ name: 'model_url', nullable: true })
  modelUrl: string;

  @Column({ length: 10, nullable: true })
  format: string; // glb, obj, usdz

  @Column({ name: 'generated_by', nullable: true })
  generatedBy: string; // AI / manual / photogrammetry

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => Product, product => product.models)
  @JoinColumn({ name: 'product_id' })
  product: Product;
} 
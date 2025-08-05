"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProductModel = void 0;
const typeorm_1 = require("typeorm");
const product_entity_1 = require("./product.entity");
let ProductModel = class ProductModel {
    id;
    productId;
    modelUrl;
    format;
    generatedBy;
    createdAt;
    product;
};
exports.ProductModel = ProductModel;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], ProductModel.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'product_id' }),
    __metadata("design:type", String)
], ProductModel.prototype, "productId", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'model_url', nullable: true }),
    __metadata("design:type", String)
], ProductModel.prototype, "modelUrl", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 10, nullable: true }),
    __metadata("design:type", String)
], ProductModel.prototype, "format", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'generated_by', nullable: true }),
    __metadata("design:type", String)
], ProductModel.prototype, "generatedBy", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: 'created_at' }),
    __metadata("design:type", Date)
], ProductModel.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => product_entity_1.Product, product => product.models),
    (0, typeorm_1.JoinColumn)({ name: 'product_id' }),
    __metadata("design:type", product_entity_1.Product)
], ProductModel.prototype, "product", void 0);
exports.ProductModel = ProductModel = __decorate([
    (0, typeorm_1.Entity)('product_models')
], ProductModel);
//# sourceMappingURL=product-model.entity.js.map
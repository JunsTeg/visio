declare const JwtAuthGuard_base: import("@nestjs/passport").Type<import("@nestjs/passport").IAuthGuard>;
export declare class JwtAuthGuard extends JwtAuthGuard_base {
    private readonly logger;
    constructor();
    handleRequest(err: any, user: any, info: any, context: any, status?: any): any;
}
export {};

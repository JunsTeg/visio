export declare class CreateUserDto {
    fullName: string;
    email: string;
    password: string;
    phoneNumber?: string;
    isVerified?: boolean;
    roleIds?: number[];
}

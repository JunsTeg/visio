import { UsersService } from './users.service';
import { CreateUserDto, UpdateUserDto } from './dto';
import { UpdateProfileDto } from './dto/update-user.dto';
export declare class UsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
    findAll(page?: number, limit?: number, search?: string, role?: string, active?: string, online?: string): Promise<{
        data: import("../entities").User[];
        total: number;
        page: number;
        limit: number;
    }>;
    findOne(id: string): Promise<import("../entities").User>;
    create(createUserDto: CreateUserDto): Promise<import("../entities").User>;
    update(id: string, updateUserDto: UpdateUserDto): Promise<import("../entities").User>;
    remove(id: string): Promise<{
        message: string;
    }>;
    updateRoles(id: string, body: {
        roleIds: number[];
    }): Promise<import("../entities").User>;
    activate(id: string): Promise<{
        message: string;
    }>;
    getMe(user: any): Promise<import("../entities").User>;
    updateMe(user: any, updateProfileDto: UpdateProfileDto): Promise<import("../entities").User>;
    getRoles(): Promise<import("../entities").Role[]>;
}

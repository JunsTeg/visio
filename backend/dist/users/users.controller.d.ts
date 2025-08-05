import { UsersService } from './users.service';
import { CreateUserDto, UpdateUserDto } from './dto';
export declare class UsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
    findAll(): Promise<import("../entities").User[]>;
    findOne(id: string): Promise<import("../entities").User>;
    create(createUserDto: CreateUserDto): Promise<import("../entities").User>;
    update(id: string, updateUserDto: UpdateUserDto): Promise<import("../entities").User>;
    remove(id: string): Promise<{
        message: string;
    }>;
    updateRoles(id: string, body: {
        roleIds: number[];
    }): Promise<import("../entities").User>;
}

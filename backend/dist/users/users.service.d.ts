import { Repository } from 'typeorm';
import { User, Role } from '../entities';
import { CreateUserDto, UpdateUserDto } from './dto';
export declare class UsersService {
    private userRepository;
    private roleRepository;
    constructor(userRepository: Repository<User>, roleRepository: Repository<Role>);
    findAll(): Promise<User[]>;
    findOne(id: string): Promise<User>;
    create(createUserDto: CreateUserDto): Promise<User>;
    update(id: string, updateUserDto: UpdateUserDto): Promise<User>;
    remove(id: string): Promise<{
        message: string;
    }>;
    updateRoles(id: string, roleIds: number[]): Promise<User>;
}

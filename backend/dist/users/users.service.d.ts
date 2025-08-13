import { Repository } from 'typeorm';
import { User, Role } from '../entities';
import { CreateUserDto, UpdateUserDto, UpdateProfileDto } from './dto';
import { UploadService } from '../upload/upload.service';
export declare class UsersService {
    private userRepository;
    private roleRepository;
    private readonly uploadService;
    constructor(userRepository: Repository<User>, roleRepository: Repository<Role>, uploadService: UploadService);
    findAll({ page, limit, search, role, active, online }: any): Promise<{
        data: User[];
        total: number;
        page: number;
        limit: number;
    }>;
    findOne(id: string): Promise<User>;
    create(createUserDto: CreateUserDto): Promise<User>;
    update(id: string, updateUserDto: UpdateUserDto): Promise<User>;
    remove(id: string): Promise<{
        message: string;
    }>;
    activate(id: string): Promise<{
        message: string;
    }>;
    updateRoles(id: string, roleIds: number[]): Promise<User>;
    getMe(userId: string): Promise<User>;
    updateMe(userId: string, updateProfileDto: UpdateProfileDto): Promise<User>;
    deleteMyAvatar(userId: string): Promise<User>;
    getRoles(): Promise<Role[]>;
}

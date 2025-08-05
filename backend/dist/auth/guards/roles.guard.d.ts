import { CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Repository } from 'typeorm';
import { User, Role } from '../../entities';
export declare class RolesGuard implements CanActivate {
    private reflector;
    private userRepository;
    private roleRepository;
    private readonly logger;
    constructor(reflector: Reflector, userRepository: Repository<User>, roleRepository: Repository<Role>);
    canActivate(context: ExecutionContext): Promise<boolean>;
}

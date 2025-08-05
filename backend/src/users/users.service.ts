import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { User, Role } from '../entities';
import { CreateUserDto, UpdateUserDto } from './dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Role)
    private roleRepository: Repository<Role>,
  ) {}

  async findAll(): Promise<User[]> {
    return this.userRepository.find({
      relations: ['roles'],
      select: ['id', 'fullName', 'email', 'phoneNumber', 'isVerified', 'createdAt'],
    });
  }

  async findOne(id: string): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id },
      relations: ['roles'],
      select: ['id', 'fullName', 'email', 'phoneNumber', 'isVerified', 'createdAt'],
    });

    if (!user) {
      throw new NotFoundException('Utilisateur non trouvé');
    }

    return user;
  }

  async create(createUserDto: CreateUserDto): Promise<User> {
    const { email, password, fullName, phoneNumber, isVerified = false, roleIds = [] } = createUserDto;

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await this.userRepository.findOne({
      where: { email },
    });

    if (existingUser) {
      throw new ConflictException('Un utilisateur avec cet email existe déjà');
    }

    // Hasher le mot de passe
    const saltRounds = 12;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Récupérer les rôles si spécifiés
    let roles: Role[] = [];
    if (roleIds.length > 0) {
      roles = await this.roleRepository.find({
        where: roleIds.map(id => ({ id }))
      });
    }

    // Créer l'utilisateur
    const user = this.userRepository.create({
      email,
      passwordHash,
      fullName,
      phoneNumber,
      isVerified,
      roles,
    });

    const savedUser = await this.userRepository.save(user);

    // Retourner l'utilisateur sans le mot de passe
    return this.findOne(savedUser.id);
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id },
      relations: ['roles'],
    });

    if (!user) {
      throw new NotFoundException('Utilisateur non trouvé');
    }

    const { email, password, fullName, phoneNumber, isVerified, roleIds } = updateUserDto;

    // Vérifier si l'email est déjà utilisé par un autre utilisateur
    if (email && email !== user.email) {
      const existingUser = await this.userRepository.findOne({
        where: { email },
      });

      if (existingUser) {
        throw new ConflictException('Un utilisateur avec cet email existe déjà');
      }
      user.email = email;
    }

    // Mettre à jour les champs
    if (fullName) user.fullName = fullName;
    if (phoneNumber !== undefined) user.phoneNumber = phoneNumber;
    if (isVerified !== undefined) user.isVerified = isVerified;

    // Mettre à jour le mot de passe si fourni
    if (password) {
      const saltRounds = 12;
      user.passwordHash = await bcrypt.hash(password, saltRounds);
    }

    // Mettre à jour les rôles si spécifiés
    if (roleIds !== undefined) {
      const roles = await this.roleRepository.find({
        where: roleIds.map(id => ({ id }))
      });
      user.roles = roles;
    }

    await this.userRepository.save(user);

    return this.findOne(id);
  }

  async remove(id: string): Promise<{ message: string }> {
    const user = await this.userRepository.findOne({
      where: { id },
    });

    if (!user) {
      throw new NotFoundException('Utilisateur non trouvé');
    }

    await this.userRepository.remove(user);

    return { message: 'Utilisateur supprimé avec succès' };
  }

  async updateRoles(id: string, roleIds: number[]): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id },
      relations: ['roles'],
    });

    if (!user) {
      throw new NotFoundException('Utilisateur non trouvé');
    }

    const roles = await this.roleRepository.find({
      where: roleIds.map(id => ({ id }))
    });
    user.roles = roles;

    await this.userRepository.save(user);

    return this.findOne(id);
  }
} 
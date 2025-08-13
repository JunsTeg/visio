import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { User, Role } from '../entities';
import { CreateUserDto, UpdateUserDto, UpdateProfileDto } from './dto';
import { UploadService } from '../upload/upload.service';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Role)
    private roleRepository: Repository<Role>,
    private readonly uploadService: UploadService,
  ) {}

  async findAll({ page = 1, limit = 20, search, role, active, online }: any): Promise<{ data: User[]; total: number; page: number; limit: number }> {
    const query = this.userRepository.createQueryBuilder('user')
      .leftJoinAndSelect('user.roles', 'userRoles');

    if (search) {
      query.andWhere('user.fullName ILIKE :search OR user.email ILIKE :search', { search: `%${search}%` });
    }
    if (role) {
      query.andWhere('userRoles.name = :role', { role });
    }
    if (active !== undefined) {
      query.andWhere('user.active = :active', { active: active === 'true' });
    }
    if (online !== undefined) {
      query.andWhere('user.online = :online', { online: online === 'true' });
    }

    const [data, total] = await query
      .skip((page - 1) * limit)
      .take(limit)
      .getManyAndCount();

    return { data, total, page: Number(page), limit: Number(limit) };
  }

  async findOne(id: string): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id },
      relations: ['roles'],
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

    const { email, password, fullName, phoneNumber, isVerified, roleIds, avatarUrl } = updateUserDto;

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
    if (avatarUrl !== undefined) user.avatarUrl = avatarUrl;
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

    user.active = false;
    user.online = false;
    await this.userRepository.save(user);

    return { message: 'Utilisateur désactivé avec succès' };
  }

  async activate(id: string): Promise<{ message: string }> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException('Utilisateur non trouvé');
    }
    user.active = true;
    user.online = false;
    await this.userRepository.save(user);
    return { message: 'Utilisateur réactivé avec succès' };
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

  async getMe(userId: string): Promise<User> {
    return this.findOne(userId);
  }

  async updateMe(userId: string, updateProfileDto: UpdateProfileDto): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id: userId },
      relations: ['roles'],
    });
    if (!user) {
      throw new NotFoundException('Utilisateur non trouvé');
    }
    const { email, password, fullName, phoneNumber, avatarUrl } = updateProfileDto;
    if (email && email !== user.email) {
      const existingUser = await this.userRepository.findOne({ where: { email } });
      if (existingUser) {
        throw new ConflictException('Un utilisateur avec cet email existe déjà');
      }
      user.email = email;
    }
    if (fullName) user.fullName = fullName;
    if (phoneNumber !== undefined) user.phoneNumber = phoneNumber;
    if (avatarUrl !== undefined) user.avatarUrl = avatarUrl;
    if (password) {
      const saltRounds = 12;
      user.passwordHash = await bcrypt.hash(password, saltRounds);
    }
    await this.userRepository.save(user);
    return this.findOne(userId);
  }

  async deleteMyAvatar(userId: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('Utilisateur non trouvé');
    }
    // Essayer de supprimer l'ancien fichier si présent
    if (user.avatarUrl) {
      const filename = user.avatarUrl.split('/').pop();
      if (filename) {
        await this.uploadService.deleteAvatarFile(filename);
      }
    }
    user.avatarUrl = null as unknown as string; // TypeORM: champ nullable
    await this.userRepository.save(user);
    return this.findOne(userId);
  }

  async getRoles(): Promise<Role[]> {
    return this.roleRepository.find();
  }
} 
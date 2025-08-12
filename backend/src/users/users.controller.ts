import { Controller, Get, Post, Body, Put, Param, Delete, UseGuards, Query } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto, UpdateUserDto } from './dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { UpdateProfileDto } from './dto/update-user.dto';

@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @Roles('admin')
  findAll(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('search') search?: string,
    @Query('role') role?: string,
    @Query('active') active?: string,
    @Query('online') online?: string,
  ) {
    return this.usersService.findAll({ page, limit, search, role, active, online });
  }

  @Get('roles')
  @Roles('admin')
  async getRoles() {
    return this.usersService.getRoles();
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  getMe(@CurrentUser() user) {
    return this.usersService.getMe(user.id);
  }

  @Put('me')
  @UseGuards(JwtAuthGuard)
  updateMe(@CurrentUser() user, @Body() updateProfileDto: UpdateProfileDto) {
    return this.usersService.updateMe(user.id, updateProfileDto);
  }

  @Post()
  @Roles('admin')
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get(':id')
  @Roles('admin')
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Put(':id')
  @Roles('admin')
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(id, updateUserDto);
  }

  @Delete(':id')
  @Roles('admin')
  remove(@Param('id') id: string) {
    return this.usersService.remove(id);
  }

  @Put(':id/roles')
  @Roles('admin')
  updateRoles(@Param('id') id: string, @Body() body: { roleIds: number[] }) {
    return this.usersService.updateRoles(id, body.roleIds);
  }

  @Put(':id/activate')
  @Roles('admin')
  async activate(@Param('id') id: string) {
    return this.usersService.activate(id);
  }
} 
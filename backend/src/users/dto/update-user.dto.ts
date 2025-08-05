import { IsEmail, IsString, MinLength, IsOptional, IsPhoneNumber, IsBoolean, IsArray, IsNumber } from 'class-validator';

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  @MinLength(2)
  fullName?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  @MinLength(6)
  password?: string;

  @IsOptional()
  @IsPhoneNumber()
  phoneNumber?: string;

  @IsOptional()
  @IsBoolean()
  isVerified?: boolean;

  @IsOptional()
  @IsArray()
  @IsNumber({}, { each: true })
  roleIds?: number[];
} 
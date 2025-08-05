import { IsEmail, IsString, MinLength, IsOptional, IsPhoneNumber, IsBoolean, IsArray, IsNumber } from 'class-validator';

export class CreateUserDto {
  @IsString()
  @MinLength(2)
  fullName: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(6)
  password: string;

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
import { IsEmail, IsString, MinLength, IsOptional, IsBoolean, IsArray, IsNumber, Matches, IsUrl } from 'class-validator';

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
  @Matches(/^[\+]?[0-9\s\-\(\)\.]{7,20}$/, {
    message: 'Format de numéro de téléphone invalide. Utilisez un format international (ex: +33123456789)'
  })
  phoneNumber?: string;

  @IsOptional()
  @IsBoolean()
  isVerified?: boolean;

  @IsOptional()
  @IsArray()
  @IsNumber({}, { each: true })
  roleIds?: number[];

  @IsOptional()
  @IsUrl({ require_tld: false, require_protocol: true }, { message: 'avatarUrl doit être une URL valide (inclure http/https)' })
  avatarUrl?: string;
}

export class UpdateProfileDto {
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
  @Matches(/^[\+]?[0-9\s\-\(\)\.]{7,20}$/, {
    message: 'Format de numéro de téléphone invalide. Utilisez un format international (ex: +33123456789)'
  })
  phoneNumber?: string;

  @IsOptional()
  @IsUrl({ require_tld: false, require_protocol: true }, { message: 'avatarUrl doit être une URL valide (inclure http/https)' })
  avatarUrl?: string;
} 
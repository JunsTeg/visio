import { IsEmail, IsString, MinLength, IsOptional, Matches, IsIn, IsUrl } from 'class-validator';

export class RegisterDto {
  @IsString()
  @MinLength(2)
  fullName: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(6)
  password: string;

  @IsOptional()
  @Matches(/^[\+]?[0-9\s\-\(\)\.]{7,20}$/, {
    message: 'Format de numéro de téléphone invalide. Utilisez un format international (ex: +33123456789)'
  })
  phoneNumber?: string;

  @IsOptional()
  @IsString()
  @IsIn(['user', 'seller'], { message: 'Rôle invalide. Valeurs autorisées: user, seller' })
  role?: string;

  @IsOptional()
  @IsUrl({}, { message: 'avatarUrl doit être une URL valide' })
  avatarUrl?: string;
} 
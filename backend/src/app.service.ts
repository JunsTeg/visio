import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

@Injectable()
export class AppService {
  constructor(
    @InjectDataSource()
    private dataSource: DataSource,
  ) {}

  getHello(): string {
    return 'Hello World!';
  }

  async testDatabaseConnection(): Promise<{ status: string; message: string }> {
    try {
      // Test de la connexion à la base de données
      await this.dataSource.query('SELECT 1');
      
      // Vérifier si les tables existent
      const tables = await this.dataSource.query(`
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public'
        ORDER BY table_name
      `);

      return {
        status: 'success',
        message: `Connexion à la base de données réussie. Tables trouvées: ${tables.map(t => t.table_name).join(', ')}`,
      };
    } catch (error) {
      return {
        status: 'error',
        message: `Erreur de connexion à la base de données: ${error.message}`,
      };
    }
  }
}

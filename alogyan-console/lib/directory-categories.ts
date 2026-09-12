export const directoryCategories = [
  { id: 'private-teachers', name: 'Private teachers', description: 'Personal guidance. At your pace.', detail: 'School subjects · Languages · Home tuition', image: 'https://images.pexels.com/photos/5212345/pexels-photo-5212345.jpeg?auto=compress&cs=tinysrgb&w=800' },
  { id: 'schools', name: 'Schools', description: 'A strong foundation for tomorrow.', detail: 'Preschools · Primary · Secondary', image: 'https://images.pexels.com/photos/256490/pexels-photo-256490.jpeg?auto=compress&cs=tinysrgb&w=800' },
  { id: 'institutes', name: 'Institutes', description: 'Build knowledge. Unlock possibilities.', detail: 'Coaching · Test preparation · Skills', image: 'https://images.pexels.com/photos/3184302/pexels-photo-3184302.jpeg?auto=compress&cs=tinysrgb&w=800' },
  { id: 'academies', name: 'Academies', description: 'Make room for what you love.', detail: 'Music · Dance · Art · Sports', image: 'https://images.pexels.com/photos/933255/pexels-photo-933255.jpeg?auto=compress&cs=tinysrgb&w=800' },
] as const;

export function isDirectoryCategory(value: string) {
  return directoryCategories.some(category => category.id === value);
}
